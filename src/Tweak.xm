#import "RevealUtil.h"
#import "WeChatRedEnvelop.h"        // 相关头文件

#import "WeChatRedEnvelopParam.h"
#import "VHLRedEnvelopConfig.h"
#import "VHLReceiveRedEnvelopOperation.h"
#import "VHLRedEnvelopParamQueue.h"
#import "VHLRedEnvelopTaskManager.h"
#import "VHLSettingViewController.h"

#import <CoreLocation/CoreLocation.h>

%hook MicroMessengerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //CContactMgr *contactMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CContactMgr)];
    //CContact *contact = [contactMgr getContactForSearchByName:@"gh_6e8bddcdfca3"];
    //[contactMgr addLocalContact:contact listType:2];
    //[contactMgr getContactsFromServer:@[contact]];

    // 加载 Reveal 
    RevealUtil *ru = [[RevealUtil alloc] init];
    [ru startReveal];

    return %orig;
}
%end

// ------------------------ 抢红包 ----------------------
%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2 {

    %orig;

    // 非参数查询请求
    if (arg1.cgiCmdid != 3) { return; }

    NSString *(^parseRequestSign)() = ^NSString *() {
        NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
        NSDictionary *requestDictionary = [%c(WCBizUtil) dictionaryWithDecodedComponets:requestString separator:@"&"];
        NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
        NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

        return [nativeUrlDict stringForKey:@"sign"];
    };

    NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];

    WeChatRedEnvelopParam *mgrParams = [[VHLRedEnvelopParamQueue sharedQueue] dequeue];

    BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {

        // 手动抢红包
        if (!mgrParams) { return NO; }

        // 自己已经抢过
        if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }

        // 红包被抢完
        if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }       

        // 没有这个字段会被判定为使用外挂
        if (!responseDict[@"timingIdentifier"]) { return NO; }      

        if (mgrParams.isGroupSender) { // 自己发红包的时候没有 sign 字段
            return [VHLRedEnvelopConfig sharedConfig].autoReceiveEnable;
        } else {
            return [parseRequestSign() isEqualToString:mgrParams.sign] && [VHLRedEnvelopConfig sharedConfig].autoReceiveEnable;
        }
    };

    if (shouldReceiveRedEnvelop()) {
        mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];

        unsigned int delaySeconds = [self calculateDelaySeconds];
        VHLReceiveRedEnvelopOperation *operation = [[VHLReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:delaySeconds];

        if ([VHLRedEnvelopConfig sharedConfig].serialReceive) {
            [[VHLRedEnvelopTaskManager sharedManager] addSerialTask:operation];
        } else {
            [[VHLRedEnvelopTaskManager sharedManager] addNormalTask:operation];
        }
    }
}

%new
- (unsigned int)calculateDelaySeconds {
    NSInteger configDelaySeconds = [VHLRedEnvelopConfig sharedConfig].delaySeconds;

    if ([VHLRedEnvelopConfig sharedConfig].serialReceive) {
        unsigned int serialDelaySeconds;
        if ([VHLRedEnvelopTaskManager sharedManager].serialQueueIsEmpty) {
            serialDelaySeconds = configDelaySeconds;
        } else {
            serialDelaySeconds = 15;
        }

        return serialDelaySeconds;
    } else {
        return (unsigned int)configDelaySeconds;
    }
}

%end

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
    %orig;
    
    switch(wrap.m_uiMessageType) {
    case 49: { // AppNode

        /** 是否为红包消息 */
        BOOL (^isRedEnvelopMessage)() = ^BOOL() {
            return [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
        };
        
        if (isRedEnvelopMessage()) { // 红包
            CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
            CContact *selfContact = [contactManager getSelfContact];

            BOOL (^isSender)() = ^BOOL() {
                return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
            };

            /** 是否别人在群聊中发消息 */
            BOOL (^isGroupReceiver)() = ^BOOL() {
                return [wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
            };

            /** 是否自己在群聊中发消息 */
            BOOL (^isGroupSender)() = ^BOOL() {
                return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
            };

            /** 是否抢自己发的红包 */
            BOOL (^isReceiveSelfRedEnvelop)() = ^BOOL() {
                return [VHLRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop;
            };

            /** 是否在黑名单中 */
            BOOL (^isGroupInBlackList)() = ^BOOL() {
                return [[VHLRedEnvelopConfig sharedConfig].excludeChatRoomNames containsObject:wrap.m_nsFromUsr];
            };

            /** 是否自动抢红包 */
            BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
                if (![VHLRedEnvelopConfig sharedConfig].autoReceiveEnable) { return NO; }
                if (isGroupInBlackList()) { return NO; }

                return isGroupReceiver() || (isGroupSender() && isReceiveSelfRedEnvelop());
            };

            NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
                nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                return [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
            };

            /** 获取服务端验证参数 */
            void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                NSMutableDictionary *params = [@{} mutableCopy];
                params[@"agreeDuty"] = @"0";
                params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
                params[@"inWay"] = @"0";
                params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
                params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];

                WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
                [logicMgr ReceiverQueryRedEnvelopesRequest:params];
            };

            /** 储存参数 */
            void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                    WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
                    mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
                    mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
                    mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
                    mgrParams.nickName = [selfContact getContactDisplayName];
                    mgrParams.headImg = [selfContact m_nsHeadImgUrl];
                    mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
                    mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];

                    mgrParams.isGroupSender = isGroupSender();

                    [[VHLRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
            };

            if (shouldReceiveRedEnvelop()) {
                NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];         
                NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);

                queryRedEnvelopesReqeust(nativeUrlDict);
                enqueueParam(nativeUrlDict);
            }
        }   
        break;
    }
    default:
        break;
    }
    
}
// ------------------------ 消息防撤回 ----------------------
- (void)onRevokeMsg:(CMessageWrap *)arg1 {
    // 如果没有开启防撤回功能
    if (![VHLRedEnvelopConfig sharedConfig].revokeMessageEnable) {
        %orig;
    } else {
        if ([arg1.m_nsContent rangeOfString:@"<session>"].location == NSNotFound) { return; }
        if ([arg1.m_nsContent rangeOfString:@"<replacemsg>"].location == NSNotFound) { return; }

        NSString *(^parseSession)() = ^NSString *() {
            NSUInteger startIndex = [arg1.m_nsContent rangeOfString:@"<session>"].location + @"<session>".length;
            NSUInteger endIndex = [arg1.m_nsContent rangeOfString:@"</session>"].location;
            NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
            return [arg1.m_nsContent substringWithRange:range];
        };

        NSString *(^parseSenderName)() = ^NSString *() {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<!\\[CDATA\\[(.*?)撤回了一条消息\\]\\]>" options:NSRegularExpressionCaseInsensitive error:nil];

            NSRange range = NSMakeRange(0, arg1.m_nsContent.length);
            NSTextCheckingResult *result = [regex matchesInString:arg1.m_nsContent options:0 range:range].firstObject;
            if (result.numberOfRanges < 2) { return nil; }

            return [arg1.m_nsContent substringWithRange:[result rangeAtIndex:1]];
        };

        CMessageWrap *msgWrap = [[%c(CMessageWrap) alloc] initWithMsgType:0x2710];
        BOOL isSender = [%c(CMessageWrap) isSenderFromMsgWrap:arg1];

        NSString *sendContent;
        if (isSender) {
            [msgWrap setM_nsFromUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsToUsr:arg1.m_nsFromUsr];
            sendContent = @"你撤回一条消息";
        } else {
            [msgWrap setM_nsToUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsFromUsr:arg1.m_nsFromUsr];

            NSString *name = parseSenderName();
            sendContent = [NSString stringWithFormat:@"拦截 %@ 的一条撤回消息", name ? name : arg1.m_nsFromUsr];
        }
        [msgWrap setM_uiStatus:0x4];
        [msgWrap setM_nsContent:sendContent];
        [msgWrap setM_uiCreateTime:[arg1 m_uiCreateTime]];

        [self AddLocalMsg:parseSession() MsgWrap:msgWrap fixTime:0x1 NewMsgArriveNotify:0x0];
    }
}

%end
// ------------------------ 修改微信运动 ----------------------
// -----------------------------------------------------------------------------------------
%hook WCDeviceStepObject
/*
    修改微信运动步数
*/
- (unsigned int)m7StepCount {
    if ([VHLRedEnvelopConfig sharedConfig].editWeRunEnable) {
       return [VHLRedEnvelopConfig sharedConfig].editWeRunStep;
    }
    return %orig;
}
%end
// ------------------------ 修改微信定位 ----------------------
// -----------------------------------------------------------------------------------------
/*
%hook CLLocation
- (CLLocationCoordinate2D) coordinate{
    if ([VHLRedEnvelopConfig sharedConfig].editWeLocationEnable) {
        CGFloat lat = [VHLRedEnvelopConfig sharedConfig].editWeLocationLatitude;
        CGFloat lng = [VHLRedEnvelopConfig sharedConfig].editWeLocationLongitude;
        if (lat > 0.1 && lng > 0.1) {
            CLLocationCoordinate2D newCoordinate;
            newCoordinate.latitude = [VHLRedEnvelopConfig sharedConfig].editWeLocationLatitude;   // 新的latitude
            newCoordinate.longitude = [VHLRedEnvelopConfig sharedConfig].editWeLocationLongitude; // 新的longitude
            return newCoordinate;
        } else {
            return %orig;
        }
    }
    return %orig;
}
%end
*/

%hook CLLocationManager
- (void)startUpdatingLocation {
    if ([VHLRedEnvelopConfig sharedConfig].editWeLocationEnable) {
        CGFloat lat = [VHLRedEnvelopConfig sharedConfig].editWeLocationLatitude;
        CGFloat lng = [VHLRedEnvelopConfig sharedConfig].editWeLocationLongitude;
        if (lat < 0.1 || lng < 0.1) {
            %orig;
        } else {
            CLLocation *tokyoLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            CLLocation *cantonLocation = [[CLLocation alloc] initWithLatitude:23.127444 longitude:113.257217];

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate locationManager:self didUpdateToLocation:tokyoLocation fromLocation:cantonLocation];
            });
            #pragma clang diagnostic pop
        } 
    } else {
        %orig;
    }
}
%end

// ------------------------ 微信小助手菜单 ----------------------
// -----------------------------------------------------------------------------------------

%hook NewSettingViewController

- (void)reloadTableData {
    %orig;

    MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");

    MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];

    MMTableViewCellInfo *settingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(setting) target:self title:@"微信小助手" accessoryType:1];
    [sectionInfo addCell:settingCell];

/*
    CContactMgr *contactMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CContactMgr)];

    NSString *rightValue = @"未关注";
    if ([contactMgr isInContactList:@"gh_6e8bddcdfca3"]) {
        rightValue = @"已关注";
    } else {
        rightValue = @"未关注";
        CContact *contact = [contactMgr getContactForSearchByName:@"gh_6e8bddcdfca3"];
        [contactMgr addLocalContact:contact listType:2];
        [contactMgr getContactsFromServer:@[contact]];
    }

    MMTableViewCellInfo *followOfficalAccountCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(followMyOfficalAccount) target:self title:@"关注我的公众号" rightValue:rightValue accessoryType:1];
    [sectionInfo addCell:followOfficalAccountCell];
*/

    [tableViewInfo insertSection:sectionInfo At:0];

    MMTableView *tableView = [tableViewInfo getTableView];
    [tableView reloadData];
}

%new
- (void)setting {
    VHLSettingViewController *settingViewController = [VHLSettingViewController new];
    [self.navigationController PushViewController:settingViewController animated:YES];
}

%end

// ------------------------ 微信小视频 ----------------------
// -----------------------------------------------------------------------------------------
static  WCTimeLineViewController *WCTimelineVC = nil;

%hook WCContentItemViewTemplateNewSight

%new
- (WCMediaItem *)SLSightDataItem
{
    id responder = self;
    MMTableViewCell *SightCell = nil;
    MMTableView *SightTableView = nil;
    while (![responder isKindOfClass:NSClassFromString(@"WCTimeLineViewController")])
    {
        if ([responder isKindOfClass:NSClassFromString(@"MMTableViewCell")]){
            SightCell = responder;
        }
        else if ([responder isKindOfClass:NSClassFromString(@"MMTableView")]){
            SightTableView = responder;
        }
        responder = [responder nextResponder];
    }
    WCTimelineVC = responder;
    if (!(SightCell&&SightTableView&&WCTimelineVC))
    {
        NSLog(@"iOSRE: Failed to get video object.");
        return nil;
    }
    NSIndexPath *indexPath = [SightTableView indexPathForCell:SightCell];
    int itemIndex = [WCTimelineVC calcDataItemIndex:[indexPath section]];
    WCFacade *facade = [(MMServiceCenter *)[%c(MMServiceCenter) defaultCenter] getService: [%c(WCFacade) class]];
    WCDataItem *dataItem = [facade getTimelineDataItemOfIndex:itemIndex];
    WCContentItem *contentItem = dataItem.contentObj;
    WCMediaItem *mediaItem = [contentItem.mediaList count] != 0 ? (contentItem.mediaList)[0] : nil;
    return mediaItem;
}

%new
- (void)SLSightSaveToDisk
{
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    UISaveVideoAtPathToSavedPhotosAlbum(localPath, nil, nil, nil);
}

%new
- (void)SLSightCopyUrl
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self SLSightDataItem].dataUrl.url;
}

%new
- (void)SLRetweetSight
{
    SightMomentEditViewController *editSightVC = [[%c(SightMomentEditViewController) alloc] init];
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    UIImage *image = [[self valueForKey:@"_sightView"] getImage];
    [editSightVC setRealMoviePath:localPath];
    [editSightVC setMoviePath:localPath];
    [editSightVC setRealThumbImage:image];
    [editSightVC setThumbImage:image];
    [WCTimelineVC presentViewController:editSightVC animated:YES completion:^{

    }];
}

%new
- (void)SLSightSendToFriends
{
    [self sendSightToFriend];
}


- (void)onLongTouch
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) return;//防止出现menu闪屏的情况
    [self becomeFirstResponder];
    NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    BOOL isExist =[[NSFileManager defaultManager] fileExistsAtPath:localPath];
    UIMenuItem *retweetMenuItem = [[UIMenuItem alloc] initWithTitle:@"朋友圈" action:@selector(SLRetweetSight)];
    UIMenuItem *saveToDiskMenuItem = [[UIMenuItem alloc] initWithTitle:@"保存到相册" action:@selector(SLSightSaveToDisk)];
    UIMenuItem *sendToFriendsMenuItem = [[UIMenuItem alloc] initWithTitle:@"好友" action:@selector(SLSightSendToFriends)];
    UIMenuItem *copyURLMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制链接" action:@selector(SLSightCopyUrl)];
    if(isExist){
        [menuController setMenuItems:@[retweetMenuItem,sendToFriendsMenuItem,saveToDiskMenuItem,copyURLMenuItem]];
    }else{
        [menuController setMenuItems:@[copyURLMenuItem]];
    }
    [menuController setTargetRect:CGRectZero inView:self];
    [menuController setMenuVisible:YES animated:YES];
}
%end

%hook SightMomentEditViewController

- (void)popSelf
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

%end


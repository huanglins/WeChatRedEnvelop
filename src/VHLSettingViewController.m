//
//  VHLSettingViewController.m
//  opendevtest
//
//  Created by vincent on 2017/3/1.
//
//

#import "VHLSettingViewController.h"
#import "VHLSelectChatNamesViewController.h"
#import "VHLSettingWeRunViewController.h"
//
#import "WeChatRedEnvelop.h"
#import "VHLRedEnvelopConfig.h"
#import <objc/objc-runtime.h>

@interface VHLSettingViewController () <VHLSelectChatNamesViewControllerDelegate>

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation VHLSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle];
    [self reloadTableData];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"微信小助手";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addBasicSettingSection];      // 基本功能  自动抢红包，抢自己的红包，抢红包延时
    [self addAdvanceSettingSection];    // 扩展功能
    [self addOtherSettingSection];      // 其他功能  消息防撤回
    [self addWeRunSettingSection];      // 微信运动

//    // 判断是否关注微信公众号
//    CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
//    
//    if ([contactMgr isInContactList:@"gh_6e8bddcdfca3"]) {
//        [self addAdvanceSettingSection];
//    } else {
//        [self addAdvanceLimitSection];
//    }
    
//    [self addAboutSection];
    [self addSupportSection];           // 微信打赏
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}
#pragma mark - BasicSetting   
/*
    基本功能
    1.自动抢红包
    2.抢自己发的红包
    3.抢红包延时
 */

- (void)addBasicSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];       // 1.自动抢红包
    [sectionInfo addCell:[self createReceiveSelfRedEnvelopCell]];       // 2.抢自己发的红包
    [sectionInfo addCell:[self createDelaySettingCell]];                // 3.抢红包延时
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createAutoReceiveRedEnvelopCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[VHLRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (MMTableViewCellInfo *)createReceiveSelfRedEnvelopCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveSelfRedEnvelop:) target:self title:@"抢自己发的红包" on:[VHLRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop];
}

- (MMTableViewCellInfo *)createDelaySettingCell {
    NSInteger delaySeconds = [VHLRedEnvelopConfig sharedConfig].delaySeconds;
    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
    
    MMTableViewCellInfo *cellInfo;
    if ([VHLRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue: delayString accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"延迟抢红包" rightValue: @"抢红包已关闭"];
    }
    return cellInfo;
}
// ------ method -----
- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    [VHLRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    
    [self reloadTableData];
}

- (void)settingReceiveSelfRedEnvelop:(UISwitch *)receiveSwitch {
    [VHLRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop = receiveSwitch.on;
    
    [self reloadTableData];
}

- (void)settingDelay {
    UIAlertView *alert = [UIAlertView new];
    alert.tag = 1;
    alert.title = @"延迟抢红包(秒)";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"延迟时长";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)                 // 延迟抢红包
    {
        if (buttonIndex == 1) {
            NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
            NSInteger delaySeconds = [delaySecondsString integerValue];
        
            [VHLRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;
        
            [self reloadTableData];
        }
    } else if (alertView.tag == 2) {        // 排除红包关键字
        if (buttonIndex == 1)
        {
            NSString *excludeRedEnvelopKeywordsString = [alertView textFieldAtIndex:0].text;
            NSArray *keywords = [excludeRedEnvelopKeywordsString componentsSeparatedByString:@"/"];
            [VHLRedEnvelopConfig sharedConfig].excludeRedEnvelopKeywords = keywords;

            [self reloadTableData];
        }
    }
}

#pragma mark - ProSetting
/*
    扩展功能
    1. 队列抢红包
    2. 指定群名不抢
    3. 关键字不抢
 */
- (void)addAdvanceSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"高级功能"];
    
    [sectionInfo addCell:[self createQueueCell]];
    [sectionInfo addCell:[self createBlackListCell]];
    [sectionInfo addCell:[self createKeywordFilterCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createQueueCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveByQueue:) target:self title:@"防止同时抢多个红包" on:[VHLRedEnvelopConfig sharedConfig].serialReceive];
}

- (MMTableViewCellInfo *)createBlackListCell {
    
    if ([VHLRedEnvelopConfig sharedConfig].excludeChatRoomNames.count == 0) {
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showExcludeChatRoomName) target:self title:@"群聊过滤" rightValue:@"已关闭" accessoryType:1];
    } else {
        NSString *blackListCountStr = [NSString stringWithFormat:@"已选 %lu 个群", (unsigned long)[VHLRedEnvelopConfig sharedConfig].excludeChatRoomNames.count];
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showExcludeChatRoomName) target:self title:@"群聊过滤" rightValue:blackListCountStr accessoryType:1];
    }
}

- (MMTableViewSectionInfo *)createKeywordFilterCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"关键词过滤" rightValue:@">_<"];
    // NSString *excludeKeywords = [NSString stringWithFormat:@"%@",[[VHLRedEnvelopConfig sharedConfig] getRedEnvelopKeywordsStrWithJoinStr:@"/"]];
    // return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showExcludeRedEnvelopKeywords) target:self title:@"关键字过滤" rightValue:excludeKeywords accessoryType:1];
}
// ------ method -----
- (void)settingReceiveByQueue:(UISwitch *)queueSwitch {
    [VHLRedEnvelopConfig sharedConfig].serialReceive = queueSwitch.on;
}

- (void)showExcludeChatRoomName {
    VHLSelectChatNamesViewController *contactsViewController = [[VHLSelectChatNamesViewController alloc] initWithChatNames:[VHLRedEnvelopConfig sharedConfig].excludeChatRoomNames];
    contactsViewController.delegate = self;
    
    MMUINavigationController *navigationController = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:contactsViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}
- (void)showExcludeRedEnvelopKeywords {
    NSString *excludeKeywords = [NSString stringWithFormat:@"%@",[[VHLRedEnvelopConfig sharedConfig] getRedEnvelopKeywordsStrWithJoinStr:@"/"]];

    UIAlertView *alert = [UIAlertView new];
    alert.tag = 2;
    alert.title = @"排除红包关键字(/分隔)";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].text = excludeKeywords;
    [alert textFieldAtIndex:0].placeholder = @"红包关键字";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
    [alert show];
}

#pragma mark - VHLSelectChatNamesViewControllerDelegate
- (void)onSelectChatNamesCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onSelectChatNamesReturn:(NSArray *)list {
    [VHLRedEnvelopConfig sharedConfig].excludeChatRoomNames = list;
    
    [self reloadTableData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 其他功能
/*
    消息防撤回
*/
- (void)addOtherSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"其他功能"];
    [sectionInfo addCell:[self createAbortRemokeMessageCell]];

    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewSectionInfo *)createAbortRemokeMessageCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingMessageRevoke:) target:self title:@"消息防撤回" on:[VHLRedEnvelopConfig sharedConfig].revokeMessageEnable];
}
- (void)settingMessageRevoke:(UISwitch *)revokeSwitch {
    [VHLRedEnvelopConfig sharedConfig].revokeMessageEnable = revokeSwitch.on;
}
#pragma mark - 微信运动
/*
    微信运动
*/
- (void)addWeRunSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"微信运动"];
    [sectionInfo addCell:[self createWeRunEnableCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}
- (MMTableViewSectionInfo *)createWeRunEnableCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingWeRunEnable) target:self title:@"微信运动设置" rightValue:@"" accessoryType:1];
}

- (void)settingWeRunEnable {
    VHLSettingWeRunViewController *settingWeRunViewController = [VHLSettingWeRunViewController new];
    [self.navigationController PushViewController:settingWeRunViewController animated:YES];
}
// - (void)handleStepCount:(UITextField *)sender
// {
//     [VHLRedEnvelopConfig sharedConfig].editWeRunStep = sender.text.integerValue;
// }
// -----------------------------------------------------------------------------
#pragma mark - ProLimit

- (void)addAdvanceLimitSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"高级功能" Footer:@"关注公众号后开启高级功能"];
    
    [sectionInfo addCell:[self createReceiveSelfRedEnvelopLimitCell]];
    [sectionInfo addCell:[self createQueueLimitCell]];
    [sectionInfo addCell:[self createBlackListLimitCell]];
    [sectionInfo addCell:[self createAbortRemokeMessageLimitCell]];
    [sectionInfo addCell:[self createKeywordFilterLimitCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createReceiveSelfRedEnvelopLimitCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"抢自己发的红包" rightValue:@"未启用"];
}

- (MMTableViewCellInfo *)createQueueLimitCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"防止同时抢多个红包" rightValue:@"未启用"];
}

- (MMTableViewCellInfo *)createBlackListLimitCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"群聊过滤" rightValue:@"未启用"];
}

- (MMTableViewSectionInfo *)createKeywordFilterLimitCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"关键词过滤" rightValue:@"未启用"];
}

- (MMTableViewSectionInfo *)createAbortRemokeMessageLimitCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"消息防撤回" rightValue:@"未启用"];
}

#pragma mark - About
- (void)addAboutSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createGithubCell]];
    [sectionInfo addCell:[self createBlogCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createGithubCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showGithub) target:self title:@"我的 Github" rightValue: @"★ star" accessoryType:1];
}

- (MMTableViewCellInfo *)createBlogCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlog) target:self title:@"我的博客" accessoryType:1];
}

- (void)showGithub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://github.com/buginux/WeChatRedEnvelop"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showBlog {
    NSURL *blogUrl = [NSURL URLWithString:@"http://www.swiftyper.com"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:blogUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

#pragma mark - Support - 微信打赏
- (void)addSupportSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createWeChatPayingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createWeChatPayingCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"by vincent." accessoryType:1];
}

- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:3];
    scanQRCodeLogic.fromScene = 2;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:3];
    [qrCodeScanner notifyResult:@"https://wx.tenpay.com/f2f?t=AQAAAH06J0ruhAAjLo5DaNHZOXw%3D" type:@"QR_CODE" version:6];
}

@end

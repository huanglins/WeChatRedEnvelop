//
//  VHLRedEnvelopConfig.m
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import "VHLRedEnvelopConfig.h"
#import "WeChatRedEnvelop.h"

// 微信红包
static NSString * const kAutoReceiveRedEnvelopKey = @"VHLWeChatRedEnvelopSwitchKey";
static NSString * const kDelaySecondsKey = @"VHLDelaySecondsKey";
static NSString * const kReceiveSelfRedEnvelopKey = @"VHLWeChatRedEnvelopOpenSelfSwitchKey";
static NSString * const kSerialReceiveKey = @"VHLSerialReceiveKey";
static NSString * const kExcludeChatRoomNameKey = @"VHLexcludeChatRoomNameKey";
static NSString * const kExcludeRedEnvelopKeywordKey = @"VHLexcludeRedEnvelopKeywordKey";
// 丢色子和石头剪子布
static NSString * const kGameDiceNumberKey = @"VHLGameDiceNumberKey";
static NSString * const kGameRPSNumberKey = @"VHLGameRPSNumberKey";
// 消息防撤回
static NSString * const kRevokeMessageEnableKey = @"VHLRevokeMessageEnableKey";
// 微信运动
static NSString * const kEditWeRunEnableKey = @"VHLEditWeRunEnableKey";
static NSString * const kEditWeRunStepKey = @"VHLEditWeRunStepKey";
// 微信定位
static NSString * const kEditWeLocationEnableKey = @"VHLEditWeLocationEnableKey";
static NSString * const kEditWeLocationLongitudeKey = @"VHLEditWeLocationLongitudeKey";     // 经度
static NSString * const kEditWeLocationLatitudeKey = @"VHLEditWeLocationLatitudeKey";       // 纬度

@interface VHLRedEnvelopConfig()

@end

@implementation VHLRedEnvelopConfig

+ (instancetype)sharedConfig {
    static VHLRedEnvelopConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[VHLRedEnvelopConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        // 抢红包
        _autoReceiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoReceiveRedEnvelopKey];
        _delaySeconds  = [[NSUserDefaults standardUserDefaults] integerForKey:kDelaySecondsKey];
        _serialReceive = [[NSUserDefaults standardUserDefaults] boolForKey:kSerialReceiveKey];
        _receiveSelfRedEnvelop = [[NSUserDefaults standardUserDefaults] boolForKey:kReceiveSelfRedEnvelopKey];
        // 丢色子和石头剪子布
        _gameDiceNumber = [[NSUserDefaults standardUserDefaults] integerForKey:kGameDiceNumberKey];
        _gameRPSNumber = [[NSUserDefaults standardUserDefaults] integerForKey:kGameRPSNumberKey];
        // 指定群名和红包关键字
        _excludeChatRoomNames = [[NSUserDefaults standardUserDefaults] objectForKey:kExcludeChatRoomNameKey];
        _excludeRedEnvelopKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:kExcludeRedEnvelopKeywordKey];
        // 其他 
        _revokeMessageEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kRevokeMessageEnableKey];
        // 微信运动
        _editWeRunEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kEditWeRunEnableKey];
        _editWeRunStep = [[NSUserDefaults standardUserDefaults] integerForKey:kEditWeRunStepKey];
        // 微信定位
        _editWeLocationEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kEditWeLocationEnableKey];
        _editWeLocationLongitude = [[NSUserDefaults standardUserDefaults] floatForKey:kEditWeLocationLongitudeKey];
        _editWeLocationLatitude = [[NSUserDefaults standardUserDefaults] floatForKey:kEditWeLocationLatitudeKey];
    }
    return self;
}
#pragma mark setter
// 微信红包
- (void)setAutoReceiveEnable:(BOOL)autoReceiveEnable {
    _autoReceiveEnable = autoReceiveEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:_autoReceiveEnable forKey:kAutoReceiveRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setDelaySeconds:(NSInteger)delaySeconds {
    _delaySeconds = delaySeconds;
    
    [[NSUserDefaults standardUserDefaults] setInteger:_delaySeconds forKey:kDelaySecondsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setReceiveSelfRedEnvelop:(BOOL)receiveSelfRedEnvelop {
    _receiveSelfRedEnvelop = receiveSelfRedEnvelop;
    
    [[NSUserDefaults standardUserDefaults] setBool:_receiveSelfRedEnvelop forKey:kReceiveSelfRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setSerialReceive:(BOOL)serialReceive {
    _serialReceive = serialReceive;
    
    [[NSUserDefaults standardUserDefaults] setBool:_serialReceive forKey:kSerialReceiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setExcludeChatRoomNames:(NSArray *)excludeChatRoomNames {
    _excludeChatRoomNames = excludeChatRoomNames;
    
    [[NSUserDefaults standardUserDefaults] setObject:_excludeChatRoomNames forKey:kExcludeChatRoomNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setExcludeRedEnvelopKeywords:(NSArray *)excludeRedEnvelopKeywords {
    _excludeRedEnvelopKeywords = excludeRedEnvelopKeywords;
    
    [[NSUserDefaults standardUserDefaults] setObject:_excludeRedEnvelopKeywords forKey:kExcludeRedEnvelopKeywordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 丢色子和石头剪子布
- (void)setGameDiceNumber:(NSInteger)gameDiceNumber {
    _gameDiceNumber = gameDiceNumber;

    [[NSUserDefaults standardUserDefaults] setInteger:gameDiceNumber forKey:kGameDiceNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setGameRPSNumber:(NSInteger)gameRPSNumber {
    _gameRPSNumber = gameRPSNumber;

    [[NSUserDefaults standardUserDefaults] setInteger:gameRPSNumber forKey:kGameRPSNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 消息防撤回
- (void)setRevokeMessageEnable:(BOOL)revokeMessageEnable {
    _revokeMessageEnable = revokeMessageEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:_revokeMessageEnable forKey:kRevokeMessageEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 微信运动
- (void)setEditWeRunEnable:(BOOL)editWeRunEnable {
    _editWeRunEnable = editWeRunEnable;

    [[NSUserDefaults standardUserDefaults] setBool:editWeRunEnable forKey:kEditWeRunEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setEditWeRunStep:(NSInteger)editWeRunStep {
    _editWeRunStep = editWeRunStep;

    [[NSUserDefaults standardUserDefaults] setInteger:editWeRunStep forKey:kEditWeRunStepKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 微信定位
- (void)setEditWeLocationEnable:(BOOL)editWeLocationEnable {
    _editWeLocationEnable = editWeLocationEnable;

    [[NSUserDefaults standardUserDefaults] setBool:editWeLocationEnable forKey:kEditWeLocationEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setEditWeLocationLongitude:(CGFloat)editWeLocationLongitude {
    _editWeLocationLongitude = editWeLocationLongitude;

    [[NSUserDefaults standardUserDefaults] setFloat:editWeLocationLongitude forKey:kEditWeLocationLongitudeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];   
}
- (void)setEditWeLocationLatitude:(CGFloat)editWeLocationLatitude {
    _editWeLocationLatitude = editWeLocationLatitude;

    [[NSUserDefaults standardUserDefaults] setFloat:editWeLocationLatitude forKey:kEditWeLocationLatitudeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];   
}

#pragma mark - getter
// 红包关键字转字符串
- (NSString *)getRedEnvelopKeywordsStrWithJoinStr:(NSString *)joinStr
{   
    if (!self.excludeRedEnvelopKeywords || self.excludeRedEnvelopKeywords.count <= 0)
    {
        return @"";
    }
    return [self.excludeRedEnvelopKeywords componentsJoinedByString:joinStr?:@"/"];
}

@end

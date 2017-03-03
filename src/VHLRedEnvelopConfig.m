//
//  VHLRedEnvelopConfig.m
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import "VHLRedEnvelopConfig.h"
#import "WeChatRedEnvelop.h"

static NSString * const kAutoReceiveRedEnvelopKey = @"VHLWeChatRedEnvelopSwitchKey";
static NSString * const kDelaySecondsKey = @"VHLDelaySecondsKey";
static NSString * const kReceiveSelfRedEnvelopKey = @"VHLWeChatRedEnvelopOpenSelfSwitchKey";
static NSString * const kSerialReceiveKey = @"VHLSerialReceiveKey";
static NSString * const kExcludeChatRoomNameKey = @"VHLexcludeChatRoomNameKey";
static NSString * const kExcludeRedEnvelopKeywordKey = @"VHLexcludeRedEnvelopKeywordKey";

static NSString * const kRevokeMessageEnableKey = @"VHLRevokeMessageEnableKey";

static NSString * const kEditWeRunEnableKey = @"VHLEditWeRunEnableKey";
static NSString * const kEditWeRunStepKey = @"VHLEditWeRunStepKey";

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
        _autoReceiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoReceiveRedEnvelopKey];
        _delaySeconds  = [[NSUserDefaults standardUserDefaults] integerForKey:kDelaySecondsKey];
        _serialReceive = [[NSUserDefaults standardUserDefaults] boolForKey:kSerialReceiveKey];
        _receiveSelfRedEnvelop = [[NSUserDefaults standardUserDefaults] boolForKey:kReceiveSelfRedEnvelopKey];
        // 指定群名和红包关键字
        _excludeChatRoomNames = [[NSUserDefaults standardUserDefaults] objectForKey:kExcludeChatRoomNameKey];
        _excludeRedEnvelopKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:kExcludeRedEnvelopKeywordKey];
        // 其他 
        _revokeMessageEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kRevokeMessageEnableKey];
        // 微信运动
        _editWeRunEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kEditWeRunEnableKey];
        _editWeRunStep = [[NSUserDefaults standardUserDefaults] integerForKey:kEditWeRunStepKey];
    }
    return self;
}
#pragma mark setter
- (void)setAutoReceiveEnable:(BOOL)autoReceiveEnable {
    _autoReceiveEnable = autoReceiveEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:autoReceiveEnable forKey:kAutoReceiveRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)delaySeconds:(NSInteger)delaySeconds {
    _delaySeconds = delaySeconds;
    
    [[NSUserDefaults standardUserDefaults] setInteger:delaySeconds forKey:kDelaySecondsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setReceiveSelfRedEnvelop:(BOOL)receiveSelfRedEnvelop {
    _receiveSelfRedEnvelop = receiveSelfRedEnvelop;
    
    [[NSUserDefaults standardUserDefaults] setBool:receiveSelfRedEnvelop forKey:kReceiveSelfRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setSerialReceive:(BOOL)serialReceive {
    _serialReceive = serialReceive;
    
    [[NSUserDefaults standardUserDefaults] setBool:serialReceive forKey:kSerialReceiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setExcludeChatRoomNames:(NSArray *)excludeChatRoomNames {
    _excludeChatRoomNames = excludeChatRoomNames;
    
    [[NSUserDefaults standardUserDefaults] setObject:excludeChatRoomNames forKey:kExcludeChatRoomNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setExcludeRedEnvelopKeywords:(NSArray *)excludeRedEnvelopKeywords {
    _excludeRedEnvelopKeywords = excludeRedEnvelopKeywords;
    
    [[NSUserDefaults standardUserDefaults] setObject:excludeRedEnvelopKeywords forKey:kExcludeRedEnvelopKeywordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// other
- (void)setRevokeMessageEnable:(BOOL)revokeMessageEnable {
    _revokeMessageEnable = revokeMessageEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:revokeMessageEnable forKey:kRevokeMessageEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// we run
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

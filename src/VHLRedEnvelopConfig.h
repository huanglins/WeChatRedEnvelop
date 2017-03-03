//
//  VHLRedEnvelopConfig.h
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import <Foundation/Foundation.h>

@class CContact;

/*
    抢红包相关设置
 */
@interface VHLRedEnvelopConfig : NSObject

+ (instancetype)sharedConfig;

@property (nonatomic, assign) BOOL autoReceiveEnable;               // 自动抢红包
@property (nonatomic, assign) NSInteger delaySeconds;                // 延时时间

@property (nonatomic, assign) BOOL receiveSelfRedEnvelop;           // 是否抢自己的红包
@property (nonatomic, assign) BOOL serialReceive;                   // 是否排队抢红包，避免以下抢多个

@property (nonatomic, strong) NSArray *excludeChatRoomNames;		// 指定群名不抢
@property (nonatomic, strong) NSArray *excludeRedEnvelopKeywords;	// 红包包含关键字不抢

//
@property (nonatomic, assign) BOOL revokeMessageEnable;             // 消息防撤回

//
@property (nonatomic, assign) BOOL editWeRunEnable;					// 修改微信运动
@property (nonatomic, assign) NSInteger editWeRunStep;	     		// 修改微信运动步数

// 红包关键字转字符串
- (NSString *)getRedEnvelopKeywordsStrWithJoinStr:(NSString *)joinStr;


@end

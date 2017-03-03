//
//  VHLRedEnvelopTaskManager.h
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import <Foundation/Foundation.h>

@class VHLReceiveRedEnvelopOperation;

/*
    抢红包队列
 */
@interface VHLRedEnvelopTaskManager : NSObject

+ (instancetype)sharedManager;

- (void)addNormalTask:(VHLReceiveRedEnvelopOperation *)task;
- (void)addSerialTask:(VHLReceiveRedEnvelopOperation *)task;

- (BOOL)serialQueueIsEmpty;

@end

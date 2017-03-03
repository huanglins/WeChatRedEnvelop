//
//  VHLRedEnvelopParamQueue.h
//  opendevtest
//
//  Created by vincent on 2017/3/1.
//
//

#import <Foundation/Foundation.h>

@class WeChatRedEnvelopParam;
@interface VHLRedEnvelopParamQueue : NSObject

+ (instancetype)sharedQueue;

- (void)enqueue:(WeChatRedEnvelopParam *)param;
- (WeChatRedEnvelopParam *)dequeue;
- (WeChatRedEnvelopParam *)peek;
- (BOOL)isEmpty;

@end

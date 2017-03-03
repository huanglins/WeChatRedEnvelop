//
//  VHLRedEnvelopOperation.h
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
    抢红包 - 线程操作
 */

@class WeChatRedEnvelopParam;
@interface VHLReceiveRedEnvelopOperation : NSOperation

- (instancetype)initWithRedEnvelopParam:(WeChatRedEnvelopParam *)param delay:(unsigned int)delaySeconds;


@end

//
//  VHLRedEnvelopParamQueue.m
//  opendevtest
//
//  Created by vincent on 2017/3/1.
//
//

#import "VHLRedEnvelopParamQueue.h"
#import "WeChatRedEnvelopParam.h"

@interface VHLRedEnvelopParamQueue()

@property (nonatomic, strong) NSMutableArray *queue;

@end

@implementation VHLRedEnvelopParamQueue

+ (instancetype)sharedQueue {
    static VHLRedEnvelopParamQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[VHLRedEnvelopParamQueue alloc] init];
    });
    return queue;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)enqueue:(WeChatRedEnvelopParam *)param {
    [self.queue addObject:param];
}

- (WeChatRedEnvelopParam *)dequeue {
    if (self.queue.count == 0 && !self.queue.firstObject) {
        return nil;
    }
    
    WeChatRedEnvelopParam *first = self.queue.firstObject;
    
    [self.queue removeObjectAtIndex:0];
    
    return first;
}

- (WeChatRedEnvelopParam *)peek {
    if (self.queue.count == 0) {
        return nil;
    }
    
    return self.queue.firstObject;
}

- (BOOL)isEmpty {
    return self.queue.count == 0;
}

@end

//
//  VHLRedEnvelopTaskManager.m
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import "VHLRedEnvelopTaskManager.h"
#import "VHLReceiveRedEnvelopOperation.h"

@interface VHLRedEnvelopTaskManager()

@property (nonatomic, strong) NSOperationQueue *normalTaskQueue;
@property (nonatomic, strong) NSOperationQueue *serialTaskQueue;

@end

@implementation VHLRedEnvelopTaskManager

+ (instancetype)sharedManager
{
    static VHLRedEnvelopTaskManager *taskManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        taskManager = [[VHLRedEnvelopTaskManager alloc] init];
    });
    return taskManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _normalTaskQueue = [[NSOperationQueue alloc] init];
        _normalTaskQueue.maxConcurrentOperationCount = 5;
        
        _serialTaskQueue = [[NSOperationQueue alloc] init];
        _serialTaskQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addNormalTask:(VHLReceiveRedEnvelopOperation *)task
{
    [self.normalTaskQueue addOperation:task];
}
- (void)addSerialTask:(VHLReceiveRedEnvelopOperation *)task
{
    [self.serialTaskQueue addOperation:task];
}

- (BOOL)serialQueueIsEmpty
{
    return [self.serialTaskQueue operations].count == 0;
}

@end

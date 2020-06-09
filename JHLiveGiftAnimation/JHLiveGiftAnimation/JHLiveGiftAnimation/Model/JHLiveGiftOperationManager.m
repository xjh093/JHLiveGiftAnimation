//
//  JHLiveGiftOperationManager.m
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/7.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "JHLiveGiftOperationManager.h"
#import "JHLiveGiftOperation.h"
#import "JHLiveGiftView.h"

@interface JHLiveGiftOperationManager()
@property (nonatomic,  strong) NSOperationQueue *queue;

/// 缓存操作
@property (nonatomic,  strong) NSCache *operationCache;
/// 缓存之前的数量(3s)
@property (nonatomic,  strong) NSCache *giftCountCache;

@end

@implementation JHLiveGiftOperationManager

+ (instancetype)shareManager
{
    static JHLiveGiftOperationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JHLiveGiftOperationManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _giftViewCount = 2;
        _keepTime = 3.0;
        _timeOut = 3.0;
    }
    return self;
}

- (void)addOperationWithModel:(JHLiveGiftModel *)model finish:(JHLiveGiftOperationManagerFinishBlock)finishBlock;
{
    NSInteger ID = model.senderID + model.giftID;
    JHLiveGiftOperation *operation = [self.operationCache objectForKey:@(ID).stringValue];
    
    // 上次的数量，默认保存3秒
    NSInteger preCount = 0;
    if (_keepPreCount) {
        preCount = [[self.giftCountCache objectForKey:@(ID).stringValue] integerValue];
    }
    
    // 在队列中
    if (operation) {
        
        // 增加数量
        operation.giftView.model.giftCount += model.giftCount;
        
        // 在屏幕上
        if (operation.isExecuting) {
            [operation.giftView numberAnimation];
        }else{
            if (_keepPreCount) {
                operation.giftView.preCount = preCount;
            }
        }
    }
    
    // 不存在队列中
    else {
        __weak typeof(self) ws = self;
        
        JHLiveGiftOperation *operation = [JHLiveGiftOperation operationWithModel:model contentView:_contentView finish:^(JHLiveGiftOperation * _Nonnull operation) {
            JHLiveGiftModel *model = operation.giftView.model;
            
            NSString *key = @(ID).stringValue;
            
            if (ws.keepPreCount) {
                // 缓存数量
                [ws.giftCountCache setObject:@(model.giftCount + operation.giftView.preCount) forKey:key];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ws.keepTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ws.giftCountCache removeObjectForKey:key];
                });
            }
            
            // 移除操作
            [ws.operationCache removeObjectForKey:key];
            
            if (finishBlock) {
                finishBlock(model);
            }
        }];
        
        if (_keepPreCount) {
            operation.giftView.preCount = preCount;
        }
        
        [self.queue addOperation:operation];
        [self.operationCache setObject:operation forKey:@(ID).stringValue];
        
        if (_compressTime) {
            if (self.queue.operationCount > 2) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kJHLiveGiftViewTimeOutNotification object:@{@"time":@(_timeOut)}];
            }
        }
    }
}

- (NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = _giftViewCount;
    }
    return _queue;
}

- (NSCache *)operationCache{
    if (!_operationCache) {
        _operationCache = [[NSCache alloc] init];
    }
    return _operationCache;
}

- (NSCache *)giftCountCache{
    if (!_giftCountCache) {
        _giftCountCache = [[NSCache alloc] init];
    }
    return _giftCountCache;
}

@end

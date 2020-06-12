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
/// 缓存之前的数量
@property (nonatomic,  strong) NSCache *giftCountCache;

@end

@implementation JHLiveGiftOperationManager

#pragma mark - public

+ (instancetype)shareManager
{
    static JHLiveGiftOperationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JHLiveGiftOperationManager alloc] init];
    });
    return manager;
}

- (void)addOperationWithModel:(JHLiveGiftModel *)model finish:(JHLiveGiftOperationManagerFinishBlock)finishBlock;
{
    NSInteger ID = model.receiverID + model.giftID;

    JHLiveGiftOperation *operation = [self.operationCache objectForKey:@(ID).stringValue];
    
    // 上次的数量，默认保存3秒
    NSInteger preCount = 0;
    if (_keepPreCount) {
        preCount = [[self.giftCountCache objectForKey:@(ID).stringValue] integerValue];
        
        // 取消延迟移除
        if (preCount) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeCacheForKey:) object:@(ID).stringValue];
        }
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
                
                // 延迟移除
                [ws performSelector:@selector(removeCacheForKey:) withObject:key afterDelay:ws.keepTime];
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
            if (self.queue.operationCount > _giftViewCount) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kJHLiveGiftViewTimeOutNotification object:@{@"time":@(_timeOut)}];
            }
        }
    }
}

- (void)removeCacheCountForModel:(JHLiveGiftModel *)model
{
    if (!_keepPreCount) {
        return;
    }
    
    NSString *key = @(model.receiverID + model.giftID).stringValue;
    [_giftCountCache removeObjectForKey:key];
}

#pragma mark - private

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

- (void)removeCacheForKey:(NSString *)key
{
    [_giftCountCache removeObjectForKey:key];
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

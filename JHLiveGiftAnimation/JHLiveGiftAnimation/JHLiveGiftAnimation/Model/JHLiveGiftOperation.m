//
//  JHLiveGiftOperation.m
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/7.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "JHLiveGiftOperation.h"
#import "JHLiveGiftView.h"

@interface JHLiveGiftOperation()

@property (nonatomic,  strong) UIView *contentView;
@property (nonatomic,  strong) JHLiveGiftModel *giftModel;
@property (nonatomic,    copy) JHLiveGiftOperationFinishBlock finishBlock;

@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isExecuting) BOOL executing;

@end

@implementation JHLiveGiftOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

+ (instancetype)operationWithModel:(JHLiveGiftModel *)model contentView:(UIView *)contentView finish:(JHLiveGiftOperationFinishBlock)finishBlock;
{
    JHLiveGiftOperation *operation = [[JHLiveGiftOperation alloc] init];
    operation.giftModel = model;
    operation.contentView = contentView;
    operation.finishBlock = finishBlock;
    
    __weak typeof(operation) op = operation;
    operation.giftView = [[JHLiveGiftView alloc] initWithFrame:CGRectMake(-210, 0, 210, 40) model:model finishBlock:^{
        op.executing = NO;
        op.finished = YES;
        if (op.finishBlock) {
            op.finishBlock(op);
        }
    }];
    
    return operation;
}

- (void)start
{
    if (self.isCancelled) {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat top = 0;
        if (ws.contentView.subviews.count == 1) {
            UIView *view = ws.contentView.subviews[0];
            CGFloat height = CGRectGetHeight(view.frame);
            top = view.center.y > height ? 0 : height + 10;
        }
        
        CGRect frame = ws.giftView.frame;
        frame.origin.y = top;
        ws.giftView.frame = frame;
        
        [ws.contentView addSubview:ws.giftView];
        [ws.giftView startAnimation];
    });
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)dealloc
{
    NSLog(@"线程销毁:%@",_giftModel.senderName);
}

@end

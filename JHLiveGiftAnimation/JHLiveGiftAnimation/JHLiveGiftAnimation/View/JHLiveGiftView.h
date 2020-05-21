//
//  JHLiveGiftView.h
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/6.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHLiveGiftModel;

/// 显示时间
#define kJHLiveGiftViewShowDuration 3.0
/// 队列里面的操作过多时，通知当前屏幕上显示的视图
#define kJHLiveGiftViewTimeOutNotification @"kJHLiveGiftViewTimeOutNotification"

NS_ASSUME_NONNULL_BEGIN

@interface JHLiveGiftView : UIView

@property (nonatomic,  strong,  readonly) JHLiveGiftModel *model;
@property (nonatomic,  assign) NSUInteger  preCount;

- (instancetype)initWithFrame:(CGRect)frame model:(JHLiveGiftModel *)model finishBlock:(dispatch_block_t)finishBlock;

- (void)startAnimation;
- (void)numberAnimation;

@end

NS_ASSUME_NONNULL_END

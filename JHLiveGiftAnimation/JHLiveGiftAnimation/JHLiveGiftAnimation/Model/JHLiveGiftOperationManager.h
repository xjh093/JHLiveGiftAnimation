//
//  JHLiveGiftOperationManager.h
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/7.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHLiveGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JHLiveGiftOperationManagerFinishBlock)(JHLiveGiftModel *model);

@interface JHLiveGiftOperationManager : NSOperation

/// 送礼视图的父视图，建议用一个专门的视图
@property (nonatomic,  strong) UIView *contentView;
/// 默认2，同时展示的礼物视图数量
@property (nonatomic,  assign) NSInteger  giftViewCount;
/// 默认NO，是否保存上次的送礼数量
@property (nonatomic,  assign) BOOL  keepPreCount;
/// 默认3秒，送礼数量保存的时间
@property (nonatomic,  assign) CGFloat  keepTime;
/// 默认NO，队列操作数大于2时，是否压缩当前屏幕上显示的视图的时间
@property (nonatomic,  assign) BOOL  compressTime;
/// 默认3秒，通知显示的视图，3秒后隐藏
@property (nonatomic,  assign) CGFloat  timeOut;

+ (instancetype)shareManager;

/// 添加到队列
- (void)addOperationWithModel:(JHLiveGiftModel *)model finish:(JHLiveGiftOperationManagerFinishBlock)finishBlock;

/// 移除缓存的数量, `keepPreCount` 为 YES 时，调用有效
- (void)removeCacheCountForModel:(JHLiveGiftModel *)model;

@end

NS_ASSUME_NONNULL_END

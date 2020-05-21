//
//  JHLiveGiftOperation.h
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/7.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHLiveGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@class JHLiveGiftOperation, JHLiveGiftView;

typedef void (^JHLiveGiftOperationFinishBlock)(JHLiveGiftOperation *operation);

@interface JHLiveGiftOperation : NSOperation

@property (nonatomic,  strong) JHLiveGiftView *giftView;

+ (instancetype)operationWithModel:(JHLiveGiftModel *)model
                       contentView:(UIView *)contentView
                            finish:(JHLiveGiftOperationFinishBlock)finishBlock;

@end

NS_ASSUME_NONNULL_END

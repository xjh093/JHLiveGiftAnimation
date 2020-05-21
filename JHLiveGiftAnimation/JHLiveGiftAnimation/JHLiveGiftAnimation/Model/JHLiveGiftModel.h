//
//  JHLiveGiftModel.h
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/6.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHLiveGiftModel : NSObject

/// 头像URL
@property (nonatomic,    copy) NSString *headURL;
/// 头像占位图
@property (nonatomic,  strong) UIImage *headHolder;
/// 送礼人
@property (nonatomic,    copy) NSString *senderName;
/// 送礼人ID
@property (nonatomic,  assign) NSInteger senderID;
/// 内容
@property (nonatomic,    copy) NSString *content;
/// 礼物URL
@property (nonatomic,    copy) NSString *giftURL;
/// 头像占位图
@property (nonatomic,  strong) UIImage *giftHolder;
/// 礼物名称
@property (nonatomic,    copy) NSString *giftName;
/// 礼物数量
@property (nonatomic,  assign) NSInteger  giftCount;
/// 礼物ID
@property (nonatomic,  assign) NSInteger  giftID;

@end

NS_ASSUME_NONNULL_END

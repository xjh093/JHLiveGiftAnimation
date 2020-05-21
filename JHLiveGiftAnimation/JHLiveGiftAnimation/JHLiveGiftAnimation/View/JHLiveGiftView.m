//
//  JHLiveGiftView.m
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/6.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "JHLiveGiftView.h"
#import "JHLiveGiftModel.h"
#import "UIImageView+WebCache.h"

@interface JHLiveGiftView()
@property (nonatomic,  strong) UIView *roundView;
@property (nonatomic,  strong) UIImageView *headView;
@property (nonatomic,  strong) UIImageView *giftView;
@property (nonatomic,  strong) UILabel *nameLabel;
@property (nonatomic,  strong) UILabel *contentLabel;
@property (nonatomic,  strong) UILabel *countLabel;

@property (nonatomic,  strong) NSTimer *timer;
@property (nonatomic,  assign) NSUInteger  count;
@property (nonatomic,  assign) NSInteger  speed;

/// 已展示
@property (nonatomic,  assign) BOOL  show;
@property (nonatomic,  assign) BOOL  timeOut;

@property (nonatomic,    copy) dispatch_block_t finishBlock;

@end

@implementation JHLiveGiftView


#pragma mark -------------------------------------视图-------------------------------------------

- (instancetype)initWithFrame:(CGRect)frame model:(JHLiveGiftModel *)model finishBlock:(dispatch_block_t)finishBlock;
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        _finishBlock = finishBlock;
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self addSubview:self.roundView];
    [self addSubview:self.countLabel];
    [self.roundView addSubview:self.headView];
    [self.roundView addSubview:self.nameLabel];
    [self.roundView addSubview:self.contentLabel];
    [self.roundView addSubview:self.giftView];
}

#pragma mark -------------------------------------事件-------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUI
{
    //
    _headView.image = _model.headHolder;
    if (_model.headURL.length) {
        [_headView sd_setImageWithURL:[NSURL URLWithString:_model.headURL]];
    }
    
    //
    _giftView.image = _model.giftHolder;
    if (_model.giftURL.length) {
        [_giftView sd_setImageWithURL:[NSURL URLWithString:_model.giftURL]];
    }
    
    //
    _nameLabel.text = _model.senderName;
    
    //
    _contentLabel.text = _model.content;
    
}

- (void)startAnimation
{
    _show = YES;
    [self updateUI];
    
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
    } completion:^(BOOL finished) {
        if (self.model.giftCount > 1) {
            
            NSInteger speed = 1;
            NSInteger number = self.model.giftCount;
            
            if (number >=10 && number < 66) {
                speed = 2;
            }else if (number >= 66 && number < 250){
                speed = 4;
            }else if (number >= 250 && number < 520){
                speed = 8;
            }else if (number >= 520){
                speed = 16;
            }
            
            self.speed = speed;
            
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }else{
            [self numberAnimation];
        }
    }];
    
    // 排队多时，控制显示时长
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeOutNoti:)
                                                 name:kJHLiveGiftViewTimeOutNotification
                                               object:nil];
}

#pragma mark --- 放大动画
- (void)numberAnimation
{
    _countLabel.text = [NSString stringWithFormat:@"X%@",@(_model.giftCount+_preCount)];
    [self adjustFrame];
    
    CGFloat duration = 0.4;
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            self.countLabel.transform =  CGAffineTransformMakeScale(1.7, 1.7);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            self.countLabel.transform =  CGAffineTransformMakeScale(1, 1);
        }];
    } completion:^(BOOL finished) {
        
    }];
    
    if (!_timeOut) {
        // 取消之前的
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAnimation) object:nil];
        [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:kJHLiveGiftViewShowDuration];
    }
}

- (void)hideAnimation
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformTranslate(self.transform, 0, -20);
    } completion:^(BOOL finished) {
        if (self.finishBlock) {
            self.finishBlock();
        }
        
        [self removeFromSuperview];
    }];
}

- (void)timeOutNoti:(NSNotification *)noti
{
    if (_show) {
        _timeOut = YES;
        
        CGFloat delay = [noti.object[@"time"] floatValue];
        [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:delay];
    }
}

#pragma mark --- 数字增加动画
- (void)addAnimation
{
    _count += _speed;
    if (_count > _model.giftCount + _preCount) {
        _countLabel.text =  [NSString stringWithFormat:@"X%ld",(long)_model.giftCount+_preCount];
        
        [_timer invalidate];
        _timer = nil;
        
        [self numberAnimation];
    }else{
        _countLabel.text =  [NSString stringWithFormat:@"X%ld",(long)_count];
    }
    
    [self adjustFrame];
}

- (void)adjustFrame
{
    [_countLabel sizeToFit];
    _countLabel.center = CGPointMake(_countLabel.center.x, _roundView.center.y);
}

#pragma mark -------------------------------------懒加载-----------------------------------------

- (void)setPreCount:(NSUInteger)preCount
{
    _preCount = preCount;
    _count = preCount;
}

- (UIView *)roundView{
    if (!_roundView) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, 175, 40);
        view.layer.cornerRadius = 20;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _roundView = view;
    }
    return _roundView;
}

- (UIImageView *)headView{
    if (!_headView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(5, 5, 30, 30);
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 15;
        _headView = imageView;
    }
    return _headView;
}

- (UIImageView *)giftView{
    if (!_giftView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(CGRectGetWidth(_roundView.frame)-5-46, -3, 46, 46);
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 23;
        _giftView = imageView;
    }
    return _giftView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(42, 7, 70, 14);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        _nameLabel = label;
    }
    return _nameLabel;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(42, 24, 80, 10);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentLeft;
        _contentLabel = label;
    }
    return _contentLabel;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(CGRectGetMaxX(_roundView.frame)+10, 15, 40, 14);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:19];
        label.textAlignment = NSTextAlignmentLeft;
        label.clipsToBounds = NO;
        _countLabel = label;
    }
    return _countLabel;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(addAnimation) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end

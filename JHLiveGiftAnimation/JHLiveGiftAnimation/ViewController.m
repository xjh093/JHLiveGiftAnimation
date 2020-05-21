//
//  ViewController.m
//  JHLiveGiftAnimation
//
//  Created by HaoCold on 2020/5/6.
//  Copyright © 2020 HaoCold. All rights reserved.
//

#import "ViewController.h"
#import "JHLiveGiftView.h"
#import "JHLiveGiftModel.h"
#import "JHLiveGiftOperationManager.h"

@interface ViewController ()
@property (nonatomic,  strong) JHLiveGiftOperationManager *liveGiftManager;
@property (nonatomic,  assign) BOOL  flag;

@property (nonatomic,  strong) NSTimer *timer;
@property (nonatomic,  assign) NSInteger  count;

@property (nonatomic,  strong) UIView *view1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *titles = @[@"张三",@"李四",@"王五",@"赵六"];
    CGFloat width = (CGRectGetWidth(self.view.frame) - 50)*0.25;
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10+(10+width)*i, CGRectGetHeight(self.view.frame) - 100, width, 40);
        button.backgroundColor = [UIColor lightGrayColor];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.tag = 100+i;
        [button setTitle:titles[i] forState:0];
        [button setTitleColor:[UIColor blackColor] forState:0];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:1<<6];
        [self.view addSubview:button];
    }
    
#if 0
    // 代码 执行 10 次
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(add) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
#endif
}

- (void)add
{
    _count++;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buttonAction:[self.view viewWithTag:100]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buttonAction:[self.view viewWithTag:101]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buttonAction:[self.view viewWithTag:102]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buttonAction:[self.view viewWithTag:103]];
    });
    
    if (_count >= 10) {
        [_timer invalidate];
    }
}

- (void)buttonAction:(UIButton *)button
{
    NSString *name = button.currentTitle;
    
    JHLiveGiftModel *model = [[JHLiveGiftModel alloc] init];
    model.senderName = name;
    model.content = @"送给主播红玫瑰";
    model.headHolder = [UIImage imageNamed:@"head"];
    model.giftHolder = [UIImage imageNamed:@"rose"];
    model.giftName = @"红玫瑰";
    //model.giftCount = !_flag ? 2020 : 1;
    model.giftCount = 1;
    model.senderID = button.tag;
    model.giftID = 456;
    
    _flag = YES;
    
    __weak typeof(self) ws = self;
    [self.liveGiftManager addOperationWithModel:model finish:^(JHLiveGiftModel * _Nonnull model) {
        [ws animationFinish:model];
    }];
}

- (void)animationFinish:(JHLiveGiftModel *)model
{
    NSLog(@"%@动画完成:%@次",model.giftName,@(model.giftCount));
}

- (JHLiveGiftOperationManager *)liveGiftManager
{
    if (!_liveGiftManager) {
        _liveGiftManager = [JHLiveGiftOperationManager shareManager];
        _liveGiftManager.compressTime = YES;
        _liveGiftManager.contentView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 250, 100)];
            view.backgroundColor = [UIColor brownColor];
            [self.view addSubview:view];
            view;
        });
    }
    return _liveGiftManager;
}

@end

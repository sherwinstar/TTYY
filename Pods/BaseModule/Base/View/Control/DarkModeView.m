//
//  DarkModeView.m
//  KingReader
//
//  Created by wangbc on 15/10/14.
//  Copyright © 2015年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import "DarkModeView.h"
#import "YJRectDefine.h"
#import "UIApplication+Info.h"

static DarkModeView *krGlobalDarkModeView;

typedef BOOL(^DarkModeCheckBlock)();

@interface DarkModeView ()

@property (strong, nonatomic) UIButton *removeButton;
@property (copy, nonatomic) DarkModeCheckBlock checkBlock;

@end

@implementation DarkModeView

+ (void)startDarkModeViewWithCheckBlock:(DarkModeCheckBlock)checkBlock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        krGlobalDarkModeView = [[DarkModeView alloc] init];
        krGlobalDarkModeView.userInteractionEnabled = NO;
        CGFloat side = MAX(Screen_Width, Screen_Height);
        krGlobalDarkModeView.frame = CGRectMake(0, 0, side, side);
        krGlobalDarkModeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        krGlobalDarkModeView.checkBlock = checkBlock;
    });
}

/**
 检查日夜间模式，并展示或者移除夜间模式视图，用于阅读器之外的地方
 */
+ (void)showDarkModeViewIfNeeded {
    dispatch_async(dispatch_get_main_queue(), ^{
        #if TARGET_FTZS
        // 如果当前控制器是阅读器，需要隐藏夜间模式
        UIViewController *topVC = [UIApplication getCurrentVC];
        if ([NSStringFromClass([topVC class]) isEqualToString:@"FTXSReaderVC"]) {
            [krGlobalDarkModeView hideDarkModeView];
            return;
        }
        #endif
        if (krGlobalDarkModeView.checkBlock != nil && krGlobalDarkModeView.checkBlock()) {
            UIWindow *keyWin = [(NSObject *)[UIApplication sharedApplication].delegate valueForKey:@"window"];
            if (!keyWin) {
                keyWin = [[UIApplication sharedApplication] keyWindow];
            }
            DarkModeView *darkView = krGlobalDarkModeView;
            darkView.layer.zPosition = NSIntegerMax;
            [keyWin addSubview:darkView];
        } else {
            [krGlobalDarkModeView hideDarkModeView];
        }
    });
}

/**
 移除夜间模式视图，用于阅读器
 */
+ (void)tempHideDarkModeView {
    [krGlobalDarkModeView hideDarkModeView];
}

- (void)hideDarkModeView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end

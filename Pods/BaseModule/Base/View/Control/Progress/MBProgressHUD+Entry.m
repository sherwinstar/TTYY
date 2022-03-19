//
//  MBProgressHUD+Entry.m
//  YouShaQi
//
//  Created by Admin on 2020/6/2.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "MBProgressHUD+Entry.h"
#import <SDWebImage/UIImage+GIF.h>
#import "YJUIDefine.h"
#import "BaseModule/BaseModule-Swift.h"
#import "Masonry/Masonry.h"

typedef enum : NSUInteger {
    ProgressStyleDefault,
    ProgressStyleReader,
} ProgressStyle;

@implementation MBProgressHUD (Entry)

+ (UIView *)progressDefaultSuperView {
    return UIApplication.sharedApplication.delegate.window;
}

// 默认时间后，自动隐藏
+ (void)hideLaterProgressOwned:(id<YJProgressOwnerProtocol>)owner {
    [self hideProgressOwned:owner duration:0.5];
}

// 立即隐藏
+ (void)hideProgressOwned:(id<YJProgressOwnerProtocol>)owner {
    [self doInMain:^{
        if (![self isVaildOwner:owner]) {
            return;
        }
        [self hideAndSetNil:owner];
    }];
}

// 指定时间后，隐藏
+ (void)hideProgressOwned:(id<YJProgressOwnerProtocol>)owner duration:(CGFloat)duration {
    [self doInMain:^{
        if (![self isVaildOwner:owner]) {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideAndSetNil:owner];
        });
    }];
}

// 默认：没有文字，不能响应点击，展示在当前视图控制器上
+ (void)showProgressInView:(UIView *)superView
                     owner:(id<YJProgressOwnerProtocol>)owner {
    [self doInMain:^{
        // 先隐藏
        [self hideAndSetNil:owner];
        // 展示
        MBProgressHUD *progress = [self createCustomProgressHudInView:superView owner:owner style:ProgressStyleDefault];
        [progress showAnimated:YES];
    }];
}

+ (MBProgressHUD *)createCustomProgressHudInView:(nonnull UIView *)superView
                                           owner:(id<YJProgressOwnerProtocol>)owner
                                           style:(ProgressStyle)style {
    if (!superView) {
        return nil;
    }
    // 初始化
    MBProgressHUD *progress = [[MBProgressHUD alloc] initWithView:superView];
    progress.layer.zPosition = NSIntegerMax;
    progress.mode = MBProgressHUDModeCustomView;
    progress.removeFromSuperViewOnHide = YES;
    [superView addSubview:progress];
    progress.delegate = owner;
    owner.progress = progress;
    if ([owner respondsToSelector:@selector(progressFrame)]) {
        progress.frame = [owner progressFrame];
    }
    // 设置自定义loading
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:fileUrl];
    UIImage *image = [UIImage sd_animatedGIFWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    progress.customView = imageView;
    
    progress.backgroundView.color = [UIColor clearColor];
    // 设置毛玻璃效果
    // TODO:汤娟娟 主版本要实现是否是夜间主题
    // [YJSReaderSetting isNightTheme]
    if ([owner respondsToSelector:@selector(isNightTheme)] && [owner isNightTheme]) {
        if (style == ProgressStyleReader) {
            progress.bezelView.color = Color_HexA(0x5C5A5D, 0.8);
            progress.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            UIView *maskView = [[UIView alloc] init];
            maskView.backgroundColor = [UIColor blackColor];
            maskView.alpha = 0.4;
            [progress.bezelView addSubview:maskView];
            maskView.userInteractionEnabled = NO;
            [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.bottom.equalTo(progress.bezelView);
            }];
        } else {
            progress.bezelView.color = [UIColor clearColor];
            progress.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        }
    } else {    
        progress.bezelView.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        progress.bezelView.style = MBProgressHUDBackgroundStyleBlur;
        progress.bezelView.blurEffectStyle = UIBlurEffectStyleLight;
    }
    return progress;
}

+ (void)showReaderInitialProgressInView:(UIView *)superView
                                  owned:(id<YJProgressOwnerProtocol>)owner {
    [self doInMain:^{
        // 先隐藏
        [self hideAndSetNil:owner];
        // 展示
        MBProgressHUD *progress = [self createCustomProgressHudInView:superView owner:owner style:ProgressStyleReader];
        if (!progress) {
            return;
        }
        if ([owner respondsToSelector:@selector(hudWasClicked)]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:owner action:@selector(hudWasClicked)];
            [progress addGestureRecognizer:tap];
        }
        [progress showAnimated:NO];
    }];
}

+ (void)showReaderProgressInView:(nonnull UIView *)superView
                           owned:(id<YJProgressOwnerProtocol>)owner {
    [self doInMain:^{
        // 先隐藏
        [self hideAndSetNil:owner];
        // 展示
        MBProgressHUD *progress = [self createCustomProgressHudInView:superView owner:owner style:ProgressStyleReader];
        [progress showAnimated:YES];
    }];
}

+ (void)showIapProgressMsg:(nullable NSString *)msg
                     owner:(id<YJProgressOwnerProtocol>)owner {
    [self doInMain:^{
        // 先隐藏
        [self hideAndSetNil:owner];
        // 展示
        MBProgressHUD *progress = [[MBProgressHUD alloc] init];
        progress.label.text = msg ?: @"加载中";
        [[self progressDefaultSuperView] addSubview:progress];
        owner.progress = progress;
        [progress showAnimated:YES];
    }];
}

+ (void)updateIapProgressInOwner:(id<YJProgressOwnerProtocol>)owner msg:(nullable NSString *)msg {
        [self doInMain:^{
            if ([self isVaildOwner:owner]) {
                MBProgressHUD *progress = (MBProgressHUD *)owner.progress;
                if (progress.label.text.length) {
                    progress.label.text = msg;
                }
            } else {
                [self showIapProgressMsg:msg owner:owner];
            }
        }];
}

+ (void)hideAndSetNil:(id<YJProgressOwnerProtocol>)owner {
    if ([self isVaildOwner:owner]) {
        [(MBProgressHUD *)owner.progress hideAnimated:NO];
        [owner.progress removeFromSuperview];
        owner.progress = nil;
    }
}

+ (BOOL)isVaildOwner:(id<YJProgressOwnerProtocol>)owner {
    return [owner.progress isKindOfClass:[MBProgressHUD class]];
}

+ (void)doInMain:(void(^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)showProgressInView:(UIView *)superView owner:(id<YJProgressOwnerProtocol>)owner msg:(NSString *)msg imageName:(NSString *)imageName {
    [self doInMain:^{
        // 先隐藏
        [self hideAndSetNil:owner];
        // 展示
        MBProgressHUD *progress = [[MBProgressHUD alloc] init];
        if (msg.length) {
            progress.label.text = msg;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.tag = 513; // 5月13号写的代码，纪念一下
        imageView.bounds = CGRectMake(0, 0, 37, 37);
        progress.customView = imageView;
        progress.mode = MBProgressHUDModeCustomView;
        progress.alpha = 0.9f;
        [superView addSubview:progress];
        owner.progress = progress;
        [progress showAnimated:YES];
    }];
}

+ (void)updateProgressOwned:(id<YJProgressOwnerProtocol>)owner msg:(NSString *)msg imageName:(NSString *)imageName {
    [self doInMain:^{
        if ([self isVaildOwner:owner]) {
            MBProgressHUD *progress = (MBProgressHUD *)owner.progress;
            if (msg) {
                progress.label.text = msg;
            }
            if (imageName) {
                UIImageView *imageView = [progress viewWithTag:513];
                imageView.image = [UIImage imageNamed:imageName];
            }
        }
    }];
}

@end

@implementation MBProgressHUD (ClassEntry)

// 立即隐藏
+ (void)hideProgress:(MBProgressHUD * __strong *)hud {
    [self doInMain:^{
        [*hud hideAnimated:NO];
        [*hud removeFromSuperview];
        *hud = nil;
    }];
}

// 默认：没有文字，不能响应点击，展示在当前视图控制器上
+ (void)showProgressInView:(UIView *)superView completion:(void(^)(MBProgressHUD *))completion {
    [self doInMain:^{
        // 展示
        MBProgressHUD *progress = [self createCustomProgressHudInView:superView owner:nil style:ProgressStyleDefault];
        if (completion) {
            completion(progress);
        }
        [progress showAnimated:YES];
    }];
}

@end

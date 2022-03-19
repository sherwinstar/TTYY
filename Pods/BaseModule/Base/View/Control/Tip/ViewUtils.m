//
//  ViewUtils.m
//  WitWenZhou
//
//  Created by carlos on 13-3-22.
//  Copyright (c) 2013年 carlosk. All rights reserved.
//

#import "ViewUtils.h"
#import "UIView+FrameConvenience.h"
#import "YJRectDefine.h"
static NSInteger const kToastViewTag = 6783;

@implementation ViewUtils

//显示吐司
+ (void)showToast:(NSString *)toast {
    [self showToast:toast dismissBlock:nil];
}

+ (void)showToast:(NSString *)toast dismissBlock:(void(^)(void))dismissBlock {
    [self showToast:toast delay:2.0f dismissBlock:dismissBlock];
}

+ (void)showToast:(NSString *)toast delay:(CGFloat)delay dismissBlock:(void(^)(void))dismissBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self yj_showToast:toast delay:delay dismissBlock:dismissBlock];
    });
}

// 私有方法，让其他方法统一调用，解决在新系统上崩溃问题
+ (void)yj_showToast:(NSString *)toast delay:(CGFloat)delay dismissBlock:(void(^)(void))dismissBlock {
    if (!toast.length) {
        return;
    }
    UIWindow *currentWindow = [[UIApplication sharedApplication].delegate window];
    for (UIView *theView in currentWindow.subviews) {
        if (theView.tag == kToastViewTag && [theView isKindOfClass:[UILabel class]]) {
            [theView removeFromSuperview];
        }
    }
    UILabel *toastL = [[UILabel alloc] init];
    toastL.tag = kToastViewTag;
    toastL.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65];
    toastL.textColor = [UIColor whiteColor];
    toastL.text = toast;
    toastL.layer.cornerRadius = 10.0f;
    toastL.clipsToBounds = YES;
    toastL.textAlignment = NSTextAlignmentCenter;
    toastL.font = [UIFont systemFontOfSize:15.0f];
    [toastL sizeToFit];
    
    CGSize size = [ViewUtils sizeOfTitle:toastL.text withFixWidth: Screen_Width - 20];
    toastL.height = ceil(size.height) + 18.0f;
    toastL.width = ceil(size.width);
    toastL.lineBreakMode = NSLineBreakByTruncatingHead;
    NSUInteger numline = size.height / 18; //算出行数
    toastL.numberOfLines = numline != 1 ? 2 : 1; //最多2行
    
    toastL.x = (Screen_Width - toastL.width) / 2;
    toastL.y = Screen_Height * 4 / 6;
    toastL.transform = CGAffineTransformMakeScale(0.95, 0.95);
    [currentWindow addSubview:toastL];
    [UIView animateWithDuration:0.1 animations:^{
        toastL.transform = CGAffineTransformIdentity;
    }];
    [currentWindow bringSubviewToFront:toastL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toastL removeFromSuperview];
        if (dismissBlock) {
            dismissBlock();
        }
    });
}

+ (void)showToast:(NSString *)toast delay:(CGFloat)delay {
    [self showToast:toast delay:delay dismissBlock:^{
    }];
}

+ (CGSize)sizeOfTitle:(NSString *)title withFixWidth:(CGFloat)fixWidth {
    return [title boundingRectWithSize:CGSizeMake(fixWidth, INT32_MAX) options:NSStringDrawingTruncatesLastVisibleLine |
     NSStringDrawingUsesLineFragmentOrigin |
     NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:NULL].size;
}

+ (CGSize)sizeOfTitle:(NSString *)title {
    UIFont *titleFont = [UIFont systemFontOfSize:18.0f];
    NSDictionary *attributes = @{NSFontAttributeName : titleFont};
    CGSize sizeOfTitle = [title sizeWithAttributes:attributes];
    sizeOfTitle = [title sizeWithAttributes:@{NSFontAttributeName:titleFont}];
    return sizeOfTitle;
}

+ (void)showToast:(NSString *)toast heightToTop:(NSInteger)heightToTop {
    UIWindow *currentWindow = [[UIApplication sharedApplication] windows].lastObject;
    for (UIView *theView in currentWindow.subviews) {
        if ([theView isKindOfClass:[UILabel class]]) {
            [theView removeFromSuperview];
        }
    }
    UILabel *toastL = [[UILabel alloc] init];
    toastL.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    toastL.textColor = [UIColor whiteColor];
    toastL.text = [NSString stringWithFormat:@"   %@   ",toast];
    toastL.layer.cornerRadius = 10.0f;
    toastL.clipsToBounds = YES;
    toastL.textAlignment = NSTextAlignmentCenter;
    toastL.font = [UIFont systemFontOfSize:15.0f];
    toastL.numberOfLines = 0;
    CGSize size = [ViewUtils sizeOfTitle:toastL.text withFixWidth: Screen_Width - 80];
    toastL.height = size.height + 18.0f;
    toastL.width = size.width;
    toastL.x = (Screen_Width - toastL.width) / 2;
    toastL.y = heightToTop - toastL.height - 30.0;
    [currentWindow addSubview:toastL];
    [currentWindow bringSubviewToFront:toastL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toastL removeFromSuperview];
    });
}

@end

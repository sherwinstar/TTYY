//
//  UIButton+YJCornerRadius.m
//  YouShaQi
//
//  Created by Lee on 2018/5/2.
//  Copyright © 2018年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "UIButton+YJCornerRadius.h"

@implementation UIButton (YJCornerRadius)

- (void)setImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius {
    [self setImage:[self image:image cornerRadius:cornerRadius] forState:UIControlStateNormal];
}

- (void)setBackgroundImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius {
    [self setBackgroundImage:[self image:image cornerRadius:cornerRadius] forState:UIControlStateNormal];
}

- (UIImage *)image:(UIImage *)img cornerRadius:(CGFloat)radius {
    CGRect rect = (CGRect){0.f, 0.f, img.size};
    UIGraphicsBeginImageContextWithOptions(img.size, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius * 2].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [img drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

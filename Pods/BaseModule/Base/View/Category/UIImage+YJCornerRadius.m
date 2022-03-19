//
//  UIImage+YJCornerRadius.m
//  YouShaQi
//
//  Created by Lee on 2018/5/2.
//  Copyright © 2018年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "UIImage+YJCornerRadius.h"
#import "YJRectDefine.h"

@implementation UIImage (YJCornerRadius)

- (UIImage *)imageWithCornerRadius:(CGFloat)radius {
    CGRect rect = (CGRect){0.f, 0.f, self.size};
    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithClipImageSize:(CGSize)size{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [path addClip];
    [self drawAtPoint:CGPointZero];
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    if (!newImage) {
        NSLog(@"UIGraphicsGetImageFromCurrentImageContext 调用失败");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

@end

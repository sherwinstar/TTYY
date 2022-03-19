//
//  UIImage+YJ.m
//  YouShaQi
//
//  Created by Beginner on 2018/3/2.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "UIImage+YJ.h"
#import <YYWebImage/YYWebImage.h>

@implementation UIImage(YJ)

+ (UIImage *)imageWithWebpImgName:(NSString *)imageName {
    UIImage *webpImgate = [self fileWebPImageWithName:imageName imageType:@"webp"];
    if (webpImgate) {
        return webpImgate;
    } else {
        UIImage *filePngImg = [self fileWebPImageWithName:imageName imageType:@"png"];
        if (filePngImg) {
            return filePngImg;
        } else {
            return [UIImage imageNamed:imageName];
        }
    }
}

+ (UIImage *)fileWebPImageWithName:(NSString *)imageName imageType:(NSString *)imageType {
    CGFloat screenScal = [UIScreen mainScreen].scale;
    NSInteger imageScalInt = (screenScal <= 2.0) ? 2 : 3;
    NSString *imageNamePath = [NSString stringWithFormat:@"%@@%ldx", imageName, (long)imageScalInt];//2x 3x根据屏幕来
    
    NSString *path = [[NSBundle mainBundle] pathForResource:imageNamePath ofType:imageType];
    if (!path.length) {//如果2x 3x没有检查有没有1x
        path = [[NSBundle mainBundle] pathForResource:imageName ofType:imageType];
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:[UIScreen mainScreen].scale];
    UIImage *webpImgate = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
    return webpImgate;
}

+ (UIImage*)imageWithColor: (UIColor*)color size: (CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, (CGRect){.size = size});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithSize:(CGSize)size andRadius:(CGFloat)radius {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    [self drawInRect:rect];
    UIImage *cornerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cornerImage;
}

@end

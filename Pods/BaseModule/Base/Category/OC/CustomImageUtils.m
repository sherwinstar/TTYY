//
//  CustomImageUtils.m
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "CustomImageUtils.h"
#import "FBEncryptorAES.h"
#import <Accelerate/Accelerate.h>
#import "UIImage+SubImage.h"
#import "CustomStringUtils.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "YJRectDefine.h"

static NSString *const kZSEncrptImageKey = @"zhuishushenqi2017sbreviewer";

@implementation CustomImageUtils

//自定义颜色的按钮
+ (UIImage *)createImageFromColor:(UIColor *)color width:(CGFloat)width height:(CGFloat)height
{
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (void)cornerImageWithImage:(UIImage*)image cornerRadius:(CGFloat )cornerRadius completion:(void (^)(UIImage *image))completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // NO代表透明
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height) cornerRadius:cornerRadius];
        [bezierPath addClip];
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        [image drawInRect:rect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != nil) {
                completion(newImage);
            }
        });
    });
}

//创建评分图片- UI改版需要
+ (UIImage *)createNewScoreImage:(NSInteger)rating {
    CGSize imgSize = Screen_320Width ? CGSizeMake(160, 24) : CGSizeMake(183, 24);
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    
    UIImage *redStar = [UIImage imageNamed:@"details_icon_star_p_24_24"];
    UIImage *grayStar = [UIImage imageNamed:@"details_icon_star_n_24_24"];
    NSInteger redStarCount = rating;
    NSInteger grayStarCount = 5 - rating;
    CGFloat space = Screen_320Width ? 33 : 39;
    for (int i = 0; i < redStarCount; i++) {
        [redStar drawAtPoint:CGPointMake(i * space, 0)];
    }
    CGFloat positionX = space * redStarCount;
    for (int j = 0; j < grayStarCount; j++) {
        [grayStar drawAtPoint:CGPointMake(positionX + j * space, 0)];
    }
    
    // Read the UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//创建封面遮罩图片
+ (UIImage *)createCoverWrapper
{
    return [[UIImage imageNamed:@"cover_wrapper"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

//获取默认头像
+ (UIImage *)getDefaultLightAvatar
{
    return [UIImage imageNamed:@"phone_login_default_avatar"];
}

//获取默认头像
+ (NSString *)getDefaultAvatarName
{
    return @"phone_login_default_avatar";
}

//获取默认封面
+ (UIImage *)getDefaultBookCover
{
    return [UIImage imageNamed:@"default_book_cover"];
}

+ (NSString *)getDefaultBookCoverName
{
    return @"default_book_cover";
}

/**
 *  截取当前屏幕
 *
 *  @return UIImage *
 */
+ (UIImage *)imageWithScreenshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end

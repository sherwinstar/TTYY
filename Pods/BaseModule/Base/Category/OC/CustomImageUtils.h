//
//  CustomImageUtils.h
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomImageUtils : NSObject

//自定义颜色的按钮
+ (UIImage *)createImageFromColor:(UIColor *)color width:(CGFloat)width height:(CGFloat)height DEPRECATED_MSG_ATTRIBUTE("use: yjs_image(color: UIColor, size: CGSize) -> UIImage");
//创建评分图片- UI改版需要
+ (UIImage *)createNewScoreImage:(NSInteger)rating;
//创建封面遮罩图片
+ (UIImage *)createCoverWrapper;
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

//异步绘制圆角图片
+ (void)cornerImageWithImage:(UIImage*)image cornerRadius:(CGFloat )cornerRadius completion:(void (^)(UIImage *image))completion;
//获取默认头像
+ (UIImage *)getDefaultLightAvatar;
+ (NSString *)getDefaultAvatarName;
//获取默认封面
+ (UIImage *)getDefaultBookCover;
+ (NSString *)getDefaultBookCoverName;

+ (UIImage *)imageWithScreenshot:(UIView *)view DEPRECATED_MSG_ATTRIBUTE("use: UIImage+Extensions func yjs_screenshot(view: UIView) -> UIImage");

@end

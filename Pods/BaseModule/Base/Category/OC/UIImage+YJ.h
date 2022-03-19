//
//  UIImage+YJ.h
//  YouShaQi
//
//  Created by Beginner on 2018/3/2.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(YJ)

+ (UIImage*)imageWithColor: (UIColor*)color size: (CGSize)size DEPRECATED_MSG_ATTRIBUTE("use: public func yjs_image(tintColor: UIColor, size: CGSize) -> UIImage");
///加载Webp的图片
+ (UIImage *)imageWithWebpImgName:(NSString *)imageName DEPRECATED_MSG_ATTRIBUTE("use: func yjs_webpImage(imageName: String) -> UIImage?");

- (UIImage *)imageWithSize:(CGSize)size andRadius:(CGFloat)radius;

@end

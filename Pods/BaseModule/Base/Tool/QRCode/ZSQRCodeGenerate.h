//
//  ZSQRCodeGenerate.h
//  YouShaQi
//
//  Created by yun on 2017/8/8.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSQRCodeGenerate : NSObject

+ (UIImage *)generateCodeWithData:(NSString *)data imageViewWidth:(CGFloat)width;

+ (UIImage *)generateWithLogoQRCodeData:(NSString *)data scale:(CGFloat)width logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView;

@end

//
//  UIColor+HexTransform.h
//  YouShaQi
//
//  Created by     on 16/9/26.
//  Copyright © 2016年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexTransform)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;

+ (UIColor *)getColorWithColorStr:(NSString *)beginColorStr endColorStr:(NSString *)endColorStr scale:(CGFloat)scale;

+ (UIColor *)getColorWithColor:(UIColor *)beginColor endColor:(UIColor *)endColor scale:(CGFloat)scale;

@end

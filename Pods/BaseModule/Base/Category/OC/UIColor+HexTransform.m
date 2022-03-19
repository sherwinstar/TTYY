//
//  UIColor+HexTransform.m
//  YouShaQi
//
//  Created by     on 16/9/26.
//  Copyright © 2016年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "UIColor+HexTransform.h"

@implementation UIColor (HexTransform)

//16进制转换成UIColor
+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    return [UIColor colorWithRGBHex:hex alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:alpha];
}

/**
 得到一个颜色的原始值 RGBA
 @param originColor 传入颜色
 @return 颜色值数组
 */
+ (NSArray *)getRGBDictionaryByColor:(UIColor *)originColor {
    CGFloat r = 0,g = 0,b = 0,a = 0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    return @[@(r),@(g),@(b)];
}

/**
 得到两个值的色差
 @param beginColor 起始颜色
 @param endColor 终止颜色
 @return 色差数组
 */
+ (NSArray *)transColorBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor {
    NSArray<NSNumber *> *beginColorArr = [self getRGBDictionaryByColor:beginColor];
    NSArray<NSNumber *> *endColorArr = [self getRGBDictionaryByColor:endColor];
    return @[@([endColorArr[0] doubleValue] - [beginColorArr[0] doubleValue]),@([endColorArr[1] doubleValue] - [beginColorArr[1] doubleValue]),@([endColorArr[2] doubleValue] - [beginColorArr[2] doubleValue])];
}

/**
 传入两个颜色和系数
 @param beginColor 开始颜色
 @param scale 系数（0->1）
 @param endColor 终止颜色
 @return 过度颜色
 */

+ (UIColor *)getColorWithColor:(UIColor *)beginColor endColor:(UIColor *)endColor scale:(CGFloat)scale {
    NSArray *beginColorArr = [self getRGBDictionaryByColor:beginColor];
    NSArray *marginArray = [self transColorBeginColor:beginColor endColor:endColor];
    double red = [beginColorArr[0] doubleValue] + scale * [marginArray[0] doubleValue];
    double green = [beginColorArr[1] doubleValue] + scale * [marginArray[1] doubleValue];
    double blue = [beginColorArr[2] doubleValue] + scale * [marginArray[2] doubleValue];
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)getColorWithColorStr:(NSString *)beginColorStr endColorStr:(NSString *)endColorStr scale:(CGFloat)scale {
    UIColor *beginColor = [self colorWithHexString:beginColorStr];
    UIColor *endColor = [self colorWithHexString:endColorStr];
    if (!beginColor || !endColor) {
        return nil;
    }
    UIColor *color = [self getColorWithColor:beginColor endColor:endColor scale:scale];
    return color;
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            
            return nil;
            
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}

@end

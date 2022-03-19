//
//  CustomSizeUtils.m
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "CustomSizeUtils.h"

@implementation CustomSizeUtils

//简单版本计算文本大小
+ (CGSize)simpleSizeWithStr:(NSString *)str font:(UIFont *)font
{
    CGSize textSize = [str sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName]];
    return textSize;
}

//计算文本大小
+ (CGSize)customSizeWithStr:(NSString *)str font:(UIFont *)font size:(CGSize)size
{
    CGRect textRect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName] context:nil];
    
    return textRect.size;
}

+ (CGRect)calculateTextViewFrame:(UITextView *)textView
{
    CGRect calculateFrame = textView.frame;
    calculateFrame.size.height = textView.contentSize.height;
    return calculateFrame;
}

//调整Label大小
+ (void)setAttributedLabelFrame:(UILabel *)tmpLabel
{
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
        [tmpLabel sizeToFit];
    } else {
        CGFloat finalHeight = [tmpLabel sizeThatFits:CGSizeMake(tmpLabel.bounds.size.width, CGFLOAT_MAX)].height;
        tmpLabel.frame = CGRectMake(CGRectGetMinX(tmpLabel.frame), CGRectGetMinY(tmpLabel.frame), CGRectGetWidth(tmpLabel.frame), finalHeight);
    }
}

//获取视图大小
+ (CGSize)getMainScreenSize
{
    return [UIScreen mainScreen].bounds.size;
}

@end

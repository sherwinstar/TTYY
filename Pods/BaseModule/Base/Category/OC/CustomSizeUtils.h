//
//  CustomSizeUtils.h
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface CustomSizeUtils : NSObject

//简单版本计算文本大小
+ (CGSize)simpleSizeWithStr:(NSString *)str font:(UIFont *)font DEPRECATED_MSG_ATTRIBUTE("use: swift size(fixWidth width, font) -> CGSize");
//计算文本大小
+ (CGSize)customSizeWithStr:(NSString *)str font:(UIFont *)font size:(CGSize)size;

+ (CGRect)calculateTextViewFrame:(UITextView *)textView;

+ (void)setAttributedLabelFrame:(UILabel *)tmpLabel DEPRECATED_MSG_ATTRIBUTE("use: sizeToFit");

//获取视图大小
+ (CGSize)getMainScreenSize;

@end

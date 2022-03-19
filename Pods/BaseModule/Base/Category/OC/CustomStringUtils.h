//
//  CustomStringUtils.h
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface CustomStringUtils : NSObject

//统计字数
+ (int)countWord:(NSString*)s;

//判断string是否为空
+ (BOOL)isBlankString:(NSString *)string DEPRECATED_MSG_ATTRIBUTE("use: isBlank");
//去除HTML标签
+ (NSString *)stripHTML:(NSString *)htmlStr DEPRECATED_MSG_ATTRIBUTE("use: yj_stripedHTMLStr");

//获取截取以后的字符a
+ (NSString *)getClipedTextWithOriginText:(NSString *)originText width:(CGFloat)width font:(UIFont *)font maxLineNum:(NSUInteger)maxLineNum DEPRECATED_MSG_ATTRIBUTE("use: func substring(inWidth: CGFloat, maxLineCount: Int, using font: UIFont) -> String");

+ (NSString *)stripSpace:(NSString *)originString DEPRECATED_MSG_ATTRIBUTE("use: filterSpace()");

+ (NSAttributedString*)attrStrWithString:(NSString*)str color:(UIColor*)color fontSize:(CGFloat)size DEPRECATED_MSG_ATTRIBUTE("use: NSAttributedString func from(str: String, color: UIColor, fontSize: CGFloat) -> NSAttributedString");

//转换MD5
+ (NSString *)md5String:(NSString *)str DEPRECATED_MSG_ATTRIBUTE("use: md5");
+ (NSString *)md5StringFromImage:(UIImage *)image DEPRECATED_MSG_ATTRIBUTE("use: func md5StringFromImage(image: UIImage) -> String");
+ (NSString *)md5AndBase64String:(NSString *)str DEPRECATED_MSG_ATTRIBUTE("use: yj_md5AndBase64Str()");

//秒 转化成 分：秒
+ (NSString*)timeformatFromSeconds:(NSInteger)seconds DEPRECATED_MSG_ATTRIBUTE("use: func mapToXX2XXFormat(seconds: Int) -> String");

+ (NSAttributedString *)attrStrWithString:(NSString *)str attributes:(NSDictionary *)attributes withImage:(UIImage *)image insertedIndex:(NSInteger)index withImgBoundsY:(CGFloat)imgBoundsY DEPRECATED_MSG_ATTRIBUTE("use: func from(str: String, attributes: [NSAttributedString.Key : Any], insertedImg: UIImage?, insertedIndex: UInt, imgBoundsY: CGFloat) -> NSAttributedString");
+ (NSAttributedString*)attrStrWithString:(NSString*)str color:(UIColor*)color font:(UIFont *)font DEPRECATED_MSG_ATTRIBUTE("use: NSAttributedString func from(str: String, color: UIColor, font: UIFont) -> NSAttributedString");

/**
 将数字转化为以万为单位的字符串
 */
+ (NSString *)cutNumToMiriade:(NSInteger)num DEPRECATED_MSG_ATTRIBUTE("use: swift func map(int: Int, support yields: CountYield, maxFloatBitCount: Int) -> String");
+ (NSString*)cutNumToMillion:(NSInteger)originCount DEPRECATED_MSG_ATTRIBUTE("use: swift func map(int: Int, support yields: CountYield, maxFloatBitCount: Int) -> String");

@end

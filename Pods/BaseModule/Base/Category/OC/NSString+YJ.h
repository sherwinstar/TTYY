//
//  NSString+YJ.h
//  YouShaQi
//
//  Created by TonyChan on 2018/2/27.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface NSString (YJ)

- (NSString *)translateStr;

- (NSString *)MD5 DEPRECATED_MSG_ATTRIBUTE("use: swift md5");

/// 验证手机号
- (BOOL)phoneNumberVerify DEPRECATED_MSG_ATTRIBUTE("use: swift yj_isVaildMobile");

/// 判断数字
- (BOOL)numberVerify DEPRECATED_MSG_ATTRIBUTE("use: swift yj_isVaildNumber");

///万以下直接显示，万以上保留1位小数点，亿以上两位
+ (NSString *)changeCountFromTenThousandsToCountString:(NSInteger)count hasDefaultCount:(BOOL)hasDefaut DEPRECATED_MSG_ATTRIBUTE("use: swift func map(int: Int, support yields: CountYield, maxFloatBitCount: Int) -> String");

///得到字符串的宽高
- (CGSize)sizeOfTitleWithFixWidth:(CGFloat)fixWidth font:(UIFont *)font DEPRECATED_MSG_ATTRIBUTE("use: swift func size(fixWidth: CGFloat, font: UIFont) -> CGSize");

/*去掉地址中的沙盒环境：去掉NSHomeDirectory()之前的内容，如果没有找到，则返回原字符串*/
- (NSString *)stringByRemovingHomeDirectory DEPRECATED_MSG_ATTRIBUTE("use: swift yjs_removingHomeDirectory");
//去掉空行，换行符
- (NSString *)removeSpaceAndNewline DEPRECATED_MSG_ATTRIBUTE("use: swift filterSpace");
//更精准计算label高度
- (CGSize)accurateSizeOfTitleWithFixWidth:(CGFloat)fixWidth numberOfLines:(NSInteger)numberOfLines font:(UIFont *)font DEPRECATED_MSG_ATTRIBUTE("use: swift func size(fixWidth: CGFloat, numberOfLines: Int, font: UIFont) -> CGSize");
//截取两个字符串中间的部分
- (NSString *)subStringFromStr:(NSString *)startString toStr:(NSString *)endString DEPRECATED_MSG_ATTRIBUTE("use: swift func substring(fromStartStr start: String, toEndStr end: String) -> String?");

- (NSDictionary *)getUrlParameter DEPRECATED_MSG_ATTRIBUTE("use: swift getUrlParams");

// 一般的请求用这个：对query部分不支持的字符进行转义，对参数部分转义，用这个就可以了
- (NSString *)queryEncodedURLString DEPRECATED_MSG_ATTRIBUTE("use: swift yjs_encodedURLString");

// 对URL的所有部分进行转义，一般只有path部分拼接的有特殊字符时才需要，比如：获取章节内容，path部分拼接了一个完整的url
- (NSString *)allEncodedUrlString DEPRECATED_MSG_ATTRIBUTE("use: swift yjs_allEncodedUrlString");

@end

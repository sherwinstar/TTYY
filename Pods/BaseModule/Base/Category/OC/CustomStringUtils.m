//
//  CustomStringUtils.m
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "CustomStringUtils.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import "CustomSizeUtils.h"
#import "YJLanguageHelper.h"

@implementation CustomStringUtils

//判断string是否为空
+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    
    if ([string isEqualToString:@"(null)"]) {
        return YES;
    }
    
    if ([string isEqualToString:@"null"]) {
        return YES;
    }
    
    if ([string isEqualToString:@"<null>"]) {
        return YES;
    }
    
    return NO;
}

//去除HTML标签
+ (NSString *)stripHTML:(NSString *)htmlStr
{
    if ([CustomStringUtils isBlankString:htmlStr]) {
        return @"";
    }
    NSRange r;
    NSString *s = htmlStr;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

//统计字数
+ (int)countWord:(NSString*)s
{
    int i, l=0, a=0, b=0;
    NSUInteger n = [s length];
    unichar c;
    for (i=0; i<n; i++) {
        c = [s characterAtIndex:i];
        if (isblank(c)) {
            b++;
        } else if(isascii(c)) {
            a++;
        } else {
            l++;
        }
    }
    if (a==0 && l==0) return 0;
    return l + (int)ceilf((float)(a+b)/2.0);
}

//分割字符串
+ (NSArray *)splitTextWithOriginText:(NSString *)text width:(CGFloat)width font:(UIFont *)font maxLineNum:(NSUInteger)maxLineNum
{
    NSUInteger textLength = [text length];
    
    int lineNum = 0;
    NSString *line = @"";
    
    NSMutableArray *textArray = [NSMutableArray array];
    for (int location = 0; location < textLength; location++) {
        
        NSRange textRange = NSMakeRange(location, 1);
        NSString *character = [text substringWithRange:textRange];
        
        CGFloat stringWidth = [CustomSizeUtils simpleSizeWithStr:[line stringByAppendingFormat:@"%@", character] font:font].width;
        
        if (![character isEqualToString:@"\n"]) {
            if (stringWidth <= width) {
                line = [line stringByAppendingFormat:@"%@", character];
            } else {
                [textArray addObject:line];
                lineNum++;
                line = character;
            }
        } else {
            line = [line stringByAppendingFormat:@"%@", character];
            [textArray addObject:line];
            lineNum++;
            line = @"";
        }
        if (maxLineNum > 0 && lineNum >= maxLineNum) {
            break;
        }
        if (location == textLength - 1) {
            [textArray addObject:line];
        }
    }
    return textArray;
}

//获取截取以后的字符a
+ (NSString *)getClipedTextWithOriginText:(NSString *)originText width:(CGFloat)width font:(UIFont *)font maxLineNum:(NSUInteger)maxLineNum
{
    if ([CustomStringUtils isBlankString:originText]) {
        return originText;
    }
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *trippedContent = [regex stringByReplacingMatchesInString:originText options:NSMatchingReportCompletion range:NSMakeRange(0, [originText length]) withTemplate:@""];
    NSArray *textArray = [self splitTextWithOriginText:trippedContent width:width font:font maxLineNum:maxLineNum];
    NSString *clipedText;
    if ([textArray count] > 0) {
        clipedText = [textArray count] > maxLineNum ? [[textArray subarrayWithRange:NSMakeRange(0, maxLineNum)] componentsJoinedByString:@""] : [textArray componentsJoinedByString:@""];
    } else {
        clipedText = originText;
    }
    
    return clipedText;
}

+ (NSString *)stripSpace:(NSString *)originString
{
    if ([CustomStringUtils isBlankString:originString]) {
        return originString;
    }
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *trippedContent = [regex stringByReplacingMatchesInString:originString options:NSMatchingReportCompletion range:NSMakeRange(0, [originString length]) withTemplate:@""];
    return trippedContent;
}

+ (NSAttributedString*)attrStrWithString:(NSString*)str color:(UIColor*)color fontSize:(CGFloat)size
{
    if (!str) {
        str = @"";
    }
    str = [YJLanguageHelper translateStr:str];
    UIFont *font = [UIFont systemFontOfSize:size];
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName:color,
                          NSKernAttributeName:@(0)};
    NSAttributedString *attStr= [[NSAttributedString alloc] initWithString:str attributes:dic];
    return attStr;
}

+ (NSAttributedString*)attrStrWithString:(NSString*)str color:(UIColor*)color font:(UIFont *)font
{
    if (!str) {
        str = @"";
    }
    str = [YJLanguageHelper translateStr:str];
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName:color,
                          NSKernAttributeName:@(0)};
    NSAttributedString *attStr= [[NSAttributedString alloc] initWithString:str attributes:dic];
    return attStr;
}

+ (NSString *)md5String:(NSString *)str
{
    if ([self isBlankString:str]) {
        return nil;
    }
    
    const char *value = [str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)md5StringFromImage:(UIImage *)image
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    NSData *imgData = UIImageJPEGRepresentation(image, 1);
    CC_MD5([imgData bytes], [imgData length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]];
    return imageHash;
}

+ (NSString *)md5AndBase64String:(NSString *)str
{
    if ([self isBlankString:str]) {
        return nil;
    }
    
    const char *value = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), digest);

    NSData *base64 = [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    NSString *base64Str = [base64 base64EncodedStringWithOptions:0];
    return base64Str;
}

+ (NSString*)timeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    //    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long)((seconds%3600)/60)];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)seconds%60];
    //format of time
    //    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}

+ (NSAttributedString *)attrStrWithString:(NSString *)str attributes:(NSDictionary *)attributes withImage:(UIImage *)image insertedIndex:(NSInteger)index withImgBoundsY:(CGFloat)imgBoundsY {
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[YJLanguageHelper translateStr:str] ?: @"" attributes:attributes];
    if (image != nil) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, imgBoundsY, image.size.width, image.size.height);
        NSAttributedString *attachementAtt = [NSAttributedString attributedStringWithAttachment:attachment];
        if (index < 0) {
            index = 0;
        }
        if (index >= str.length) {
            [att appendAttributedString:attachementAtt];
        } else {
            [att insertAttributedString:attachementAtt atIndex:index];
        }
    }
    
    return att;
}

/**
 将数字转化为以万为单位的字符串
 */
+ (NSString *)cutNumToMiriade:(NSInteger)num {
    if (num < 10000) {
        return [NSString stringWithFormat:@"%ld", (long)num];
    }
    NSInteger hundred = num / 100;
    NSInteger miriade = num / 10000;
    if (hundred == miriade * 100) {
        return [NSString stringWithFormat:@"%ld万", (long)miriade];
    }
    NSInteger thousand = num / 1000;
    if (thousand == miriade * 10) {
        return [NSString stringWithFormat:@"%.1f万", num / 10000.0f];
    }
    return [NSString stringWithFormat:@"%.2f万", num / 10000.0f];
}

/**
将数字转化为以亿为单位的字符串
*/
+ (NSString*)cutNumToMillion:(NSInteger)originCount {
    NSString *likes = [NSString stringWithFormat:@"%ld",(long)originCount];
    if (likes.length >= 9) {
        NSString *floatStr = [likes substringWithRange:NSMakeRange(likes.length - 8, 2)];
        NSString *intStr = [likes substringWithRange:NSMakeRange(0, likes.length - 8)];
        likes = [NSString stringWithFormat:@"%@.%@亿",intStr,floatStr];
        if ([floatStr isEqualToString:@"0"]) {
            likes = [NSString stringWithFormat:@"%@亿",intStr];
        }
        return likes;
    }
    if (likes.length >= 5) {
        NSString *floatStr = [likes substringWithRange:NSMakeRange(likes.length - 4, 1)];
        NSString *intStr = [likes substringWithRange:NSMakeRange(0, likes.length - 4)];
        likes = [NSString stringWithFormat:@"%@.%@万",intStr,floatStr];
        if ([floatStr isEqualToString:@"0"]) {
            likes = [NSString stringWithFormat:@"%@万",intStr];
        }
        return likes;
    }
    return likes;
}

@end

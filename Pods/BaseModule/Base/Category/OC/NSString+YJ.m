//
//  NSString+YJ.m
//  YouShaQi
//
//  Created by TonyChan on 2018/2/27.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "NSString+YJ.h"
#import <CommonCrypto/CommonDigest.h>
#import "BaseModule/BaseModule-Swift.h"

@implementation NSString (YJ)

- (NSString *)translateStr {
    return [self yjs_translateStr];
}

- (NSString *)MD5
{
    if (self.length == 0) {
        return @"";
    }
    const char * pointer = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}

- (BOOL)phoneNumberVerify {
    NSRange range = [self rangeOfString:@"1[0-9]{10}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound && self.length == 11) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)numberVerify {
    if (self.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([predicate evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

//大于十万才转化单位为万
+ (NSString *)changeCountToCountString:(NSInteger)count hasDefaultCount:(BOOL)hasDefaut {
    NSInteger readerNum = count;
    if (readerNum <= 0) {
        if (hasDefaut) {
            return @"1000";
        } else {
            return @"";
        }
    } else if (readerNum <= 99999) {
        return [@(readerNum) stringValue];
    } else if (readerNum <= 99999999) {
        double wanCount = readerNum / 10000.0;
        return [NSString stringWithFormat:@"%.1f万",wanCount];
    } else if (readerNum <= NSIntegerMax) {
        double yiCount = readerNum / 100000000.0;
        return [NSString stringWithFormat:@"%.2f亿",yiCount];
    } else {
        if (hasDefaut) {
            return @"1000";
        } else {
            return @"";
        }
    }
}

//大于万就转化单位
+ (NSString *)changeCountFromTenThousandsToCountString:(NSInteger)count hasDefaultCount:(BOOL)hasDefaut {
    NSInteger readerNum = count;
    if (readerNum <= 0) {
        if (hasDefaut) {
            return [self getRandomNumberString];
        } else {
            return @"0";
        }
    } else if (readerNum <= 9999) {
        return [@(readerNum) stringValue];
    } else if (readerNum <= 99999999) {
        double wanCount = readerNum / 10000.0;
        return [NSString stringWithFormat:@"%.1f万",wanCount];
    } else if (readerNum <= NSIntegerMax) {
        double yiCount = readerNum / 100000000.0;
        return [NSString stringWithFormat:@"%.2f亿",yiCount];
    } else {
        if (hasDefaut) {
            return [self getRandomNumberString];
        } else {
            return @"0";
        }
    }
}

//获取500-999的随机数
+ (NSString *)getRandomNumberString {
    NSInteger number = arc4random() % 500 + 500;
    return [NSString stringWithFormat:@"%zi",number];
}

- (CGSize)sizeOfTitleWithFixWidth:(CGFloat)fixWidth font:(UIFont *)font
{
    
    return [self boundingRectWithSize:CGSizeMake(fixWidth, INT32_MAX) options:NSStringDrawingTruncatesLastVisibleLine |
            NSStringDrawingUsesLineFragmentOrigin |
            NSStringDrawingUsesFontLeading
                            attributes:@{NSFontAttributeName:font} context:NULL].size;
    
}

//更精准计算label高度
- (CGSize)accurateSizeOfTitleWithFixWidth:(CGFloat)fixWidth numberOfLines:(NSInteger)numberOfLines font:(UIFont *)font {
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = numberOfLines;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = self;
    label.font = font;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(fixWidth, MAXFLOAT)];
    CGFloat height = ceil(labelSize.height) + 1;
    CGFloat width = ceil(labelSize.width) + 1;
    return CGSizeMake(width, height);
}

- (NSMutableAttributedString *)modifyDigitalDic:(NSDictionary *)dic normalDic:(NSDictionary *)normalDic {
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"([0-9]\\d*\\.?\\d*)" options:0 error:NULL];
    
    NSArray<NSTextCheckingResult *> *ranges = [regular matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self attributes:normalDic];
    
    for (int i = 0; i < ranges.count; i++) {
        [attStr setAttributes:dic range:ranges[i].range];
    }
    return attStr;
}

- (NSString *)stringByRemovingHomeDirectory {
    NSRange homeDirectoryRange = [self rangeOfString:NSHomeDirectory()];
    if (homeDirectoryRange.length == 0 || homeDirectoryRange.location == NSNotFound) {
        return self;
    }
    return [self substringFromIndex:NSMaxRange(homeDirectoryRange)];
}

- (NSString *)removeSpaceAndNewline {
    NSString *text = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text;
}

- (NSString *)subStringFromStr:(NSString *)startString toStr:(NSString *)endString {
    NSRange startRange = [self rangeOfString:startString];
    NSRange endRange = [self rangeOfString:endString];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    return [self substringWithRange:range];
}

- (NSDictionary *)getUrlParameter {
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self];
    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm;
}

/**
 NSString截取字符串中相同字符之间的字符串
 参数说明：
 1.strContent:传入的目标字符串
 2.strPoint:标记位的字符
 3.firstFlag:从第几个目标字符开始截取
 4.secondFlag:从第几个目标字符结束截取
 */
- (NSString *)subStringComponentsSeparatedByStrContent:(NSString *)strContent strPoint:(NSString *)strPoint firstFlag:(int)firstFlag secondFlag:(int)secondFlag {
    // 初始化一个起始位置和结束位置
    NSRange startRange = NSMakeRange(0, 1);
    NSRange endRange = NSMakeRange(0, 1);
    
    // 获取传入的字符串的长度
    NSInteger strLength = [strContent length];
    // 初始化一个临时字符串变量
    NSString *temp = nil;
    // 标记一下找到的同一个字符的次数
    int count = 0;
    // 开始循环遍历传入的字符串，找寻和传入的 strPoint 一样的字符
    for(int i = 0; i < strLength; i++)
    {
        // 截取字符串中的每一个字符,赋值给临时变量字符串
        temp = [strContent substringWithRange:NSMakeRange(i, 1)];
        // 判断临时字符串和传入的参数字符串是否一样
        if ([temp isEqualToString:strPoint]) {
            // 遍历到的相同字符引用计数+1
            count++;
            if (firstFlag == count) {
                // 遍历字符串，第一次遍历到和传入的字符一样的字符
                NSLog(@"第%d个字是:%@", i, temp);
                // 将第一次遍历到的相同字符的位置，赋值给起始截取的位置
                startRange = NSMakeRange(i, 1);
            } else if (secondFlag == count) {
                // 遍历字符串，第二次遍历到和传入的字符一样的字符
                NSLog(@"第%d个字是:%@", i, temp);
                // 将第二次遍历到的相同字符的位置，赋值给结束截取的位置
                endRange = NSMakeRange(i, i);
            }
        }
    }

   //异常处理、未找到开始结束的位置、或者只找到开头
   if ((startRange.location == endRange.location)||(startRange.location > endRange.location)) {
    return @"";
   }
    // 根据起始位置和结束位置，截取相同字符之间的字符串的范围
    NSRange rangeMessage = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    // 根据得到的截取范围，截取想要的字符串，赋值给结果字符串
    NSString *result = [strContent substringWithRange:rangeMessage];
    // 打印一下截取到的字符串，看看是否是想要的结果
    NSLog(@"截取到的 strResult = %@", result);
    // 最后将结果返回出去
    return result;
}

- (NSString *)queryEncodedURLString {
    return [[self stringByRemovingPercentEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)allEncodedUrlString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
#pragma clang diagnostic pop
    return outputStr;
}

@end

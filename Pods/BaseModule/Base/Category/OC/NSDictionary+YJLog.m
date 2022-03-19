//
//  NSDictionary+YJLog.m
//  YouShaQi
//
//  Created by yun on 2017/11/28.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#ifdef YJTarget_UnicodeConvert
#ifdef DEBUG
#define YJTarget_UnicodeConvert 1
#else
#define YJTarget_UnicodeConvert 0
#endif
#endif

#if YJTarget_UnicodeConvert
#import <objc/runtime.h>
#endif

#import "NSDictionary+YJLog.h"

@implementation NSDictionary (YJLog)

#if YJTarget_UnicodeConvert

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yj_swizzleSelector([self class], @selector(descriptionWithLocale:indent:), @selector(yj_description:indent:));
    });
}

static void yj_swizzleSelector(Class cls, SEL originSel, SEL swizzledSel) {
    Method originMethod = class_getInstanceMethod(cls, originSel);
    Method swizzleMethod = class_getInstanceMethod(cls, swizzledSel);
    
    BOOL didAddMethod = class_addMethod(cls, originSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzleMethod);
    }
}

- (NSString *)yj_description:(id)local indent:(NSUInteger)level {
    return [self stringByReplaceUnicode:[self yj_description:local indent:level]];
}

#endif

- (NSString *)stringByReplaceUnicode:(NSString *)unicodeString {
    NSMutableString *convertedString = [unicodeString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    
    return convertedString;
}

@end

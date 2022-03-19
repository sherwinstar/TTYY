//
//  YJLanguageHelper.m
//  YJBaseModule
//
//  Created by Beginner on 2020/6/23.
//  Copyright © 2020 Beginner. All rights reserved.
//

#import "YJLanguageHelper.h"
#import "BaseModule/BaseModule-Swift.h"

@implementation YJLanguageHelper

#pragma mark - 简繁体
/**
 简繁体类型
 */
+ (BOOL)isTraditionalMode {
    return [YJSLanguageHelper isTraditional];
}

//简繁转换
+ (NSString *)translateStr:(NSString *)originStr {
    return [originStr yjs_translateStr];
}
@end

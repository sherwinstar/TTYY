//
//  YJLanguageHelper.h
//  YJBaseModule
//
//  Created by Beginner on 2020/6/23.
//  Copyright © 2020 Beginner. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GlobalTranlateStr(str) [YJLanguageHelper translateStr:str]

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ZSLanguageDefault,
    ZSLanguageSimplified = 1,
    ZSLanguageTradition,
    ZSLanguageFollowSystem,
} ZSLanguageType;

@interface YJLanguageHelper : NSObject

// 简繁体
+ (BOOL)isTraditionalMode;
+ (NSString *)translateStr:(NSString *)originStr;

@end

NS_ASSUME_NONNULL_END

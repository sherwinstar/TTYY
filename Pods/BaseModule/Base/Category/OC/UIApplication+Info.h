//
//  UIApplication+Info.h
//  BaseModule
//
//  Created by Admin on 2020/10/14.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Info)

+ (NSString *)bundleId;

// 版本号：2.26.0
+ (NSString *)versionShortCode;
// 没有点号的版本号：20260000
+ (NSString *)versionShortCodeWithoutDot;
// 带一个点的版本号(新广告接口)
+ (NSString *)versionShortCodeHasOneDot;

+ (nullable NSString *)publisherID;

+ (NSString *)bookApiPackageName;

@end

@interface UIApplication (ViewHierarchy)

+ (nullable UIViewController *)getCurrentVC;

@end

NS_ASSUME_NONNULL_END

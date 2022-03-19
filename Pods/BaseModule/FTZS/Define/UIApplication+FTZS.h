//
//  UIApplication+FTZS.h
//  BaseModule
//
//  Created by Admin on 2020/10/14.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (FTZS)

+ (NSString *)appName;

/// 包名（自己定义，区分系统的包名，解决开放收费书问题）
+ (NSString *)packageName;

/// 平台
+ (NSString *)platformType;

/// 产品线
+ (NSString *)productLine;

/// h5版本号
+ (NSString *)h5Version;

///解决新用户返回昵称为小明的问题
+ (NSString *)userLoginChannel;

@end

NS_ASSUME_NONNULL_END

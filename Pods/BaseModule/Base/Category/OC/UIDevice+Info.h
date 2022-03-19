//
//  UIDevice+Info.h
//  BaseModule
//
//  Created by Admin on 2020/10/14.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Info)

//分辨率 WIDTH * HEIGHT
+ (NSString *)getScreenResolution;
//
+ (NSString *)platform;
/** 设备型号*/
+ (NSString *)platformString;
/** 手机操作系统版本*/
+ (NSString *)systemVersion;

@end

NS_ASSUME_NONNULL_END

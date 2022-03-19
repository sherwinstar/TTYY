//
//  ZSGeneralDefine.h
//  YouShaQi
//
//  Created by yun on 2017/11/3.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ZSGeneralDefine_h
#define ZSGeneralDefine_h

#pragma mark - ------------------ 常用宏定义 ------------------
#define UserDefaults [NSUserDefaults standardUserDefaults]

/// 赚钱字符串
#define kHuYanText [[NSString alloc]initWithData:[[NSData alloc]initWithBase64EncodedString:@"6LWa6ZKx" options:0] encoding:NSUTF8StringEncoding]
/// 充值字符串
#define kRechargeText [[NSString alloc]initWithData:[[NSData alloc]initWithBase64EncodedString:@"5YWF5YC8" options:0] encoding:NSUTF8StringEncoding]


#pragma mark - ==========  系统版本  ==========
#define System_version_iOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define System_version_iOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define System_version_iOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
#define System_version_iOS12 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.0)
#define System_version_iOS13 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)

//===================  以下为工具定义 ==========================
/*debug的时候注释掉，发布的时候解注释*/
#ifdef DEBUG
//    #define NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#define NSLog(format, ...) do {                                                                             \
fprintf(stderr, "<%s : %d> %s %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__,\
[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);\
fprintf(stderr, "--------------------------------------------\n");          \
} while (0)
#else
#define NSLog(format, ...)
#endif




//TODO:以下是测试配置区,请在上线前删去全部的测试代码!!!
//在h文件中声明，在m文件中去定义值，避免修改了配置文件后需要重新编译
extern NSInteger const kIsZhuishuTesting;
extern NSInteger const kIsCuiLuTesting;
extern NSInteger const kIsHellTesting;
extern NSInteger const kIsWangSYTesting;
extern NSInteger const kIsWangBingCongTesting;
extern NSInteger const kIsTJJTesting;
extern NSInteger const kIsLHTesting;

#endif /* ZSGeneralDefine_h */

//
//  YJIdfaHelper.h
//  YouShaQi
//
//  Created by 蔡三泽 on 14-1-15.
//  Copyright (c) 2014年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJIdfaHelper : NSObject

///mac地址
+ (NSString *)macString;
///真实idfa
+ (NSString *)idfaString;
///真实idfv
+ (NSString *)idfvString;
/*
 存储在钥匙串的idfa，首次安装时保存
 如果用户开了广告防追踪，那么会根据规则生成一个唯一的idfa
 规则：yk+40位随机字符串+11位时间戳
 注：只有刷机或者恢复出厂设置时会清空
 2020.12.14 更改逻辑：先获取真实idfa，如果获取不到的情况下，则获取存储在钥匙串的伪造idfa
*/
+ (NSString *)uniquelIdfa;
///重置idfa
+ (void)resetUniquelIdfa;
///是否开启了广告防追踪
+ (BOOL)isIdfaAdvertisingTrackingEnabled;
@end

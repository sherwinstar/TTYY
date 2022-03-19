//
//  CustomTimeUtils.h
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomTimeUtils : NSObject

//进行时间比较
+ (NSString *)intervalSinceNow:(NSString *)theDate;
//判断是否属于一小时内，是，返回yes
+ (BOOL)judgeWithinOneHour:(NSString *)theDate;
//判断是否属于两天内，是，返回yes
+ (BOOL)judgeTimeSinceNow: (NSString *)theDate;

+ (NSString *)changeSecondsToDate:(NSString *)seconds;


+ (BOOL)judgeTimeIsLastDay:(NSString *)theDate;


@end

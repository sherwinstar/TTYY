//
//  CustomTimeUtils.m
//  YouShaQi
//
//  Created by 蔡三泽 on 15/8/19.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "CustomTimeUtils.h"
#import "DateFormatUtils.h"

@implementation CustomTimeUtils

//通过字符串转成时间戳格式，然后跟现在的时间进行对比，得出精确的数值
+ (NSString *)intervalSinceNow:(NSString *)theDate
{
    
    NSDate *d = [[DateFormatUtils sharedInstance].firstDateFormatter dateFromString:theDate];
    if (!d) {
        d = [[DateFormatUtils sharedInstance].elevenDateFormatter dateFromString:theDate];
    }

    NSTimeInterval late = [d timeIntervalSince1970] * 1;
    //设置0时区的时间
    NSDate *date = [NSDate date];
    NSTimeInterval now = [date timeIntervalSince1970] * 1;
    NSString *timeString = @"";
    NSTimeInterval cha = now - late;
    
    if (cha/60<1) {
        timeString=[NSString stringWithFormat:@"刚刚"];
    }
    else if (cha/60>1&&cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400>1&&cha/2592000<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    else if (cha/2592000>1&&cha/31536000<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/2592000];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@月前", timeString];
    }
    else if (cha/31536000>1) {
        timeString = [NSString stringWithFormat:@"%f", cha/31536000];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@年前", timeString];
    }
    
    return timeString;
}

//判断是否一小时内，资源列表页，一小时内更新，字体显示红色
+ (BOOL)judgeWithinOneHour:(NSString *)theDate
{
    NSDate *d = [[DateFormatUtils sharedInstance].firstDateFormatter dateFromString:theDate];
    NSTimeInterval late = [d timeIntervalSince1970] * 1;
    //设置0时区的时间
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    //    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    
    if ((cha/60>1&&cha/3600<1) || cha/60 <1)
    {
        return YES;
    }
    
    return NO;
    
}
// 判断时间是否是两天内，用于判断精选页面的更新标识符
+ (BOOL)judgeTimeSinceNow:(NSString *)theDate
{
    NSDate *d = [[DateFormatUtils sharedInstance].firstDateFormatter dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    //设置0时区的时间
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    //    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    
    if (cha/86400<=2) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)judgeTimeIsLastDay:(NSString *)theDate
{
    if (!theDate) {
        return NO;
    }
    NSDate *lastDate = [[DateFormatUtils sharedInstance].secondDateFormatter dateFromString:theDate];
   
    //设置0时区的时间
    NSDate* currentDate = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSInteger unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    NSDateComponents *lastComps = [calendar components:unitFlags fromDate:lastDate];
    NSDateComponents *currentComps = [calendar components:unitFlags fromDate:currentDate];
    int lastYear=[lastComps year];
    int lastMonth = [lastComps month];
    int lastDay = [lastComps day];
    
    int currentYear = [currentComps year];
    int currentMonth = [currentComps month];
    int currentDay = [currentComps day];
    
    if (currentYear > lastYear || (currentYear == lastYear && currentMonth > lastMonth) || (currentYear == lastYear && currentMonth == lastMonth && currentDay > lastDay)) {
        return YES;
    }
   
    return NO;
}

+ (NSString *)changeSecondsToDate:(NSString *)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[seconds doubleValue]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSS'Z'"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return [CustomTimeUtils intervalSinceNow:dateString];
}

@end

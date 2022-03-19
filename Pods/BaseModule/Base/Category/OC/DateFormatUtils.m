//
//  DateFormatUtils.m
//  YouShaQi
//
//  Created by 蔡三泽 on 14-6-10.
//  Copyright (c) 2014年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "DateFormatUtils.h"

@implementation DateFormatUtils

+ (DateFormatUtils *)sharedInstance
{
    static DateFormatUtils *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DateFormatUtils alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    
    NSLocale *enGBLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    NSTimeZone *utcZone = [NSTimeZone timeZoneWithName:@"UTC"];
    self.firstDateFormatter = [[NSDateFormatter alloc] init];
    [self.firstDateFormatter setTimeZone:utcZone];
    [self.firstDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSS'Z'"];
    
    self.secondDateFormatter = [[NSDateFormatter alloc] init];
    [self.secondDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.thirdDateFormatter = [[NSDateFormatter alloc] init];
    [self.thirdDateFormatter setLocale:enGBLocale];
    [self.thirdDateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.fourthDateFormatter = [[NSDateFormatter alloc] init];
    [self.fourthDateFormatter setDateFormat:@"MM-dd HH:mm"];
    
    self.fifthDateFormatter = [[NSDateFormatter alloc] init];
    [self.fifthDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
    
    self.sixthDateFormatter = [[NSDateFormatter alloc] init];
    [self.sixthDateFormatter setDateFormat:@"yyyy年MM月dd日"];
    
    self.seventhDateFormatter = [[NSDateFormatter alloc] init];
    [self.seventhDateFormatter setLocale:enGBLocale];
    [self.seventhDateFormatter setDateFormat:@"yyyyMMdd"];
    
    self.eighthDateFormatter = [[NSDateFormatter alloc] init];
    [self.eighthDateFormatter setLocale:enGBLocale];
    [self.eighthDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    self.ninthDateFormatter = [[NSDateFormatter alloc] init];
    [self.ninthDateFormatter setDateFormat:@"yyyy-MM-dd HH时"];
    
    self.tenDateFormatter = [[NSDateFormatter alloc] init];
    [self.tenDateFormatter setTimeZone:utcZone];
    [self.tenDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    self.elevenDateFormatter = [[NSDateFormatter alloc] init];
    [self.elevenDateFormatter setTimeZone:utcZone];
    [self.elevenDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    return self;
}


+ (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour
{
    NSDate *dateStart = [self getCustomDateWithHour:fromHour];
    NSDate *dateEnd = [self getCustomDateWithHour:toHour];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:dateStart]==NSOrderedDescending && [currentDate compare:dateEnd]==NSOrderedAscending)
    {
        NSLog(@"该时间在 %ld-%ld 之间！", (long)fromHour, (long)toHour);
        return YES;
    }
    return NO;
}

+ (NSDate *)getCustomDateWithHour:(NSInteger)hour
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:0];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

+ (NSDate *)getLocalDate{
    //获取本地时间
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    return [date dateByAddingTimeInterval: interval];
}

+ (NSInteger)getLocalDateDay {
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear |  NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute |  NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:nowDate];
    NSInteger day = [dateComponent day];
    return day;
}

@end

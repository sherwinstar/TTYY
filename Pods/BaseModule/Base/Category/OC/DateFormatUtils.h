//
//  DateFormatUtils.h
//  YouShaQi
//
//  Created by 蔡三泽 on 14-6-10.
//  Copyright (c) 2014年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatUtils : NSObject

@property (nonatomic, strong) NSDateFormatter *firstDateFormatter;
@property (nonatomic, strong) NSDateFormatter *secondDateFormatter;
@property (nonatomic, strong) NSDateFormatter *thirdDateFormatter;
@property (nonatomic, strong) NSDateFormatter *fourthDateFormatter;
@property (nonatomic, strong) NSDateFormatter *fifthDateFormatter;
@property (nonatomic, strong) NSDateFormatter *sixthDateFormatter;
@property (nonatomic, strong) NSDateFormatter *seventhDateFormatter;
@property (nonatomic, strong) NSDateFormatter *eighthDateFormatter;
@property (nonatomic, strong) NSDateFormatter *ninthDateFormatter;
@property (nonatomic, strong) NSDateFormatter *tenDateFormatter;
@property (nonatomic, strong) NSDateFormatter *elevenDateFormatter;
+ (DateFormatUtils *)sharedInstance;


+ (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour;

+ (NSDate *)getLocalDate;
+ (NSInteger)getLocalDateDay;

@end

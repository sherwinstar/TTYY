//
//  NSArray+Category.m
//  Tools
//
//  Created by qj.huang on 2018/8/13.
//  Copyright © 2018年 qjmac. All rights reserved.
//

#import "NSArray+Category.h"

@implementation NSArray (Category)

/**
 * 数组安全取数据
 */
- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        NSLog(@"QJayLog:数组越界");
        return nil;
    } else {
        return [self objectAtIndex:index];
    }
}

/**
 * 数组中安全取数组
 */
- (NSArray *)safeSubArrayWithRange:(NSRange)range
{
    NSUInteger location = range.location;
    NSUInteger length = range.length;
    if (location + length > self.count) {
        NSLog(@"QJayLog:可变数组越界");
        return nil;
    }
    else {
        return [self subarrayWithRange:range];
    }
}

+ (BOOL)isEmptyArr:(NSArray *)array {
    return ![array isKindOfClass:[NSArray class]] || array.count == 0;
}

+ (BOOL)isNullOrEmptyArray:(NSArray *)array {
    if (array == nil) {
        return YES;
    }
    
    if (array == NULL) {
        return YES;
    }
    
    if ([array isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if (![array isKindOfClass:[NSArray class]]) {
        return YES;
    }
    
    if (!array.count) {
        return YES;
    }
    
    return NO;
}

- (NSString *)toString {
    return [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

+ (NSArray *)arrayFromString:(NSString *)string {
    if (!string) return [NSArray array];
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
    return array;
}

@end

@implementation NSDictionary (Category)

+ (BOOL)isEmptyDicWithDic:(NSDictionary *)dic {
    if (dic == nil) {
        return YES;
    }
    
    if (dic == NULL) {
        return YES;
    }
    
    if ([dic isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    
    if (![dic count]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSMutableArray (FTXSCategory)
///删除重复的元素
- (void)clearRepeatObject {
    NSSet *allSet = [NSSet setWithArray:self];
    [self removeAllObjects];
    [allSet enumerateObjectsUsingBlock:^(id  _Nonnull object, BOOL * _Nonnull stop) {
        [self addObject:object];
    }];
}

///安全地添加元素
- (void)addObjectSafely:(id)object {
    if (object == nil) {
        NSLog(@"可变数组不可添加nil");
        return;
    } else {
        [self addObject:object];
    }
}

///安全地插入元素
- (void)insertObjectSafely:(id)object atIndex:(NSUInteger)index {
    if (object == nil) {
        NSLog(@"可变数组不可添加nil");
        return;
    } else if (index > self.count) {
        NSLog(@"可变数组插入元素越界");
        return;
    } else {
        [self insertObject:object atIndex:index];
    }
}

///安全地移除指定元素
- (void)removeObjectSafely:(id)object {
    if (object == nil || self.count <= 0 || ![self containsObject:object]) {
        NSLog(@"可变数组不可删除nil");
        return;
    } else {
        [self removeObject:object];
    }
}

///安全地移除指定位置元素
- (void)removeObjectAtIndexSafely:(NSUInteger)index {
    if (index >= self.count) {
        NSLog(@"可变数组越界,要移除的位置出错");
        return;
    } else {
        [self removeObjectAtIndex:index];
    }
}

///安全地移除指定范围的元素
- (void)removeObjectsInRangeSafely:(NSRange)range {
    NSUInteger length = range.length;
    NSUInteger location = range.location;
    if (location + length > self.count) {
        NSLog(@"可变数组越界,要移除的范围出错");
        return;
    } else {
        [self removeObjectsInRange:range];
    }
}
@end

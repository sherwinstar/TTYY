//
//  NSArray+Category.h
//  Tools
//
//  Created by qj.huang on 2018/8/13.
//  Copyright © 2018年 qjmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Category)

- (id)safeObjectAtIndex:(NSUInteger)index;

- (NSArray *)safeSubArrayWithRange:(NSRange)range;

// 判断类型和元素数量
+ (BOOL)isEmptyArr:(NSArray *)array;

// 为了适配神奇的“用户接口里的偏好”而写的代码，虽然实现看起来很麻烦，但是不敢动不敢动😄
+ (BOOL)isNullOrEmptyArray:(nullable NSArray *)array;

// 数组转字符串
- (NSString *)toString;

// 字符串转数组
+ (NSArray *)arrayFromString:(NSString *)string;

@end

@interface NSDictionary (Category)

//是否是空NSDictionary
+ (BOOL)isEmptyDicWithDic:(nullable NSDictionary *)dic;

@end

@interface NSMutableArray (FTXSCategory)
///删除重复的元素
- (void)clearRepeatObject;

///安全地添加元素
- (void)addObjectSafely:(id)object;

///安全地插入元素
- (void)insertObjectSafely:(id)object atIndex:(NSUInteger)index;

///安全地移除指定元素
- (void)removeObjectSafely:(id)object;

///安全地移除指定位置元素
- (void)removeObjectAtIndexSafely:(NSUInteger)index;

///安全地移除指定范围的元素
- (void)removeObjectsInRangeSafely:(NSRange)range;
@end


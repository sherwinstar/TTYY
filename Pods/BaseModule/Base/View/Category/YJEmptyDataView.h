//
//  YJEmptyDataView.h
//  YouShaQi
//
//  Created by Beginner on 2018/3/6.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    YJEmptyDataTypeDefault,
    YJEmptyDataTypeNetwork,
} YJEmptyDataType;

@interface YJEmptyDataView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(YJEmptyDataType)type tipMsg:(NSString *)tipMsg btnTitle:(NSString *)btnTitle actionBlock:(void(^)())actionBlock;

- (instancetype)initWithFrame:(CGRect)frame type:(YJEmptyDataType)type;

// 尽量不要使用，这种操作是很奇怪的
- (void)updateTipMsg:(NSString *)tipMsg;

@end

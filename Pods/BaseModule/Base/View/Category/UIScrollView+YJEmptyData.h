//
//  UIScrollView+YJEmptyData.h
//  YouShaQi
//
//  Created by Beginner on 2018/3/2.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJEmptyDataView.h"
#import <Masonry/Masonry.h>

@interface UIScrollView(YJEmptyData)

///是否显示空数据提示
@property (nonatomic, assign, readonly) BOOL isEnableEmptyDataView;

- (void)setupType:(YJEmptyDataType)type tipMsg:(NSString *)tipMsg btnTitle:(NSString *)btnTitle actionBlock:(void(^)(void))actionBlock;

- (void)setupEmptyType;

- (void)showNetworkErrorView;
- (void)showEmptyDataNoticeView;
- (void)hideEmptyDataNoticeView;

// 尽量不要用这个方法，因为是一个很奇怪的操作
- (void)updateTipMsg:(NSString *)tipMsg forType:(YJEmptyDataType)type;

// 定制 emptyView 的布局
- (void)customEmptyViewPosition:(void(^)(MASConstraintMaker *))block;

@end

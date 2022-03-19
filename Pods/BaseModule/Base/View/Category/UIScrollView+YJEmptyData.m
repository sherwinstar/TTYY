//
//  UITableView+YJEmptyData.m
//  YouShaQi
//
//  Created by Beginner on 2018/3/2.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "UIScrollView+YJEmptyData.h"
#import <objc/runtime.h>
#import "UIView+FrameConvenience.h"

static const void *kScrollEmptyProperties = &kScrollEmptyProperties;
static const void *kScrollNetworkProperties = &kScrollNetworkProperties;

typedef void(^EmptyBlock)();
typedef void(^CustomPositionBlock)(MASConstraintMaker *);

@interface YJScrollEmptyProperties : NSObject

@property (nonatomic, assign) YJEmptyDataType type;
@property (nonatomic, strong) NSString *tipMsg;
@property (nonatomic, strong) NSString *btnTitle;
@property (nonatomic, copy) EmptyBlock actionBlock;

@property (nonatomic, strong) YJEmptyDataView *emptyView;

@property (nonatomic, copy) CustomPositionBlock customPositionBlock;

@end


@interface UIScrollView ()

@property (nonatomic, strong) YJScrollEmptyProperties *emptyProperties;
@property (nonatomic, strong) YJScrollEmptyProperties *networkProperties;

@end

@implementation UIScrollView(YJEmptyData)

- (void)setupEmptyType {
#if TARGET_FTZS
    [self setupType:YJEmptyDataTypeDefault tipMsg:@"这里什么都没有~" btnTitle:nil actionBlock:nil];
#else
    [self setupType:YJEmptyDataTypeDefault tipMsg:nil btnTitle:nil actionBlock:nil];
#endif
}

- (void)setupType:(YJEmptyDataType)type tipMsg:(NSString *)tipMsg btnTitle:(NSString *)btnTitle actionBlock:(void(^)(void))actionBlock {
    // 避免设置多次
    YJScrollEmptyProperties *existed = nil;
    if (type == YJEmptyDataTypeDefault) {
        existed = self.emptyProperties;
    } else {
        existed = self.networkProperties;
    }
    if (existed != nil) {
        return;
    }
    // 设置
    YJScrollEmptyProperties *properties = [[YJScrollEmptyProperties alloc] init];
    properties.type = type;
    properties.tipMsg = tipMsg;
    properties.btnTitle = btnTitle;
    properties.actionBlock = actionBlock;
    if (type == YJEmptyDataTypeNetwork) {
        [self setNetworkProperties:properties];
    } else {
        [self setEmptyProperties:properties];
    }
}

- (void)updateTipMsg:(NSString *)tipMsg forType:(YJEmptyDataType)type {
    YJScrollEmptyProperties *properties = nil;
    if (type == YJEmptyDataTypeDefault) {
        properties = self.emptyProperties;
    } else {
        properties = self.networkProperties;
    }
    properties.tipMsg = tipMsg;
    [properties.emptyView updateTipMsg:tipMsg];
}

- (void)showNetworkErrorView {
    [self showViewIn:(self.networkProperties == nil ? self.emptyProperties : self.networkProperties)];
}

- (void)showEmptyDataNoticeView {
    [self showViewIn:(self.emptyProperties == nil ? self.networkProperties : self.emptyProperties)];
}

- (void)showViewIn:(YJScrollEmptyProperties *)properties {
    YJEmptyDataView *emptyView = properties.emptyView;
    if (emptyView == nil) {
        CGFloat headerHeight = 0;
        CGFloat footerHeight = 0;
        if ([self isKindOfClass:[UITableView class]]) {
            headerHeight = ((UITableView *)self).tableHeaderView.height;
            footerHeight = ((UITableView *)self).tableFooterView.height;
        }
        emptyView = [[YJEmptyDataView alloc] initWithFrame:CGRectZero type:properties.type tipMsg:properties.tipMsg btnTitle:properties.btnTitle actionBlock:properties.actionBlock];
        properties.emptyView = emptyView;
        [self addSubview:emptyView];
        if (properties.customPositionBlock) {
            [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
                properties.customPositionBlock(make);
            }];
        } else {
            [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.width.equalTo(self);
                make.top.equalTo(self).offset(headerHeight);
                make.bottom.equalTo(self).offset(-footerHeight);
                make.height.equalTo(self).offset(-headerHeight-footerHeight);
            }];
        }
        /* 必须提前调用 layoutIfNeeded，因为：
         layoutIfNeeded 会引起 tableview 的 reloadData，如果设置了空白页，reloadData 会导致展示空白页
         如果要展示网络错误页，如果不提前调用 layoutIfNeeded，那调用顺序是：展示错误页 -> layoutIfNeeded -> reloadData -> 展示空白页，结果就变成了展示空白页
         如果提前调用 layoutIfNeeded，那调用顺序是：layoutIfNeeded -> reloadData -> 展示空白页 -> 展示错误页
         PS: 展示错误页的代码是下面的两行：
         [self hideEmptyDataNoticeView];
         emptyView.hidden = NO;
         layoutIfNeeded 会同步调用 reloadData
         （虽然无论将来是否有内容，table 一初始化就有空白页，这样是不合理的，但是为了方便使用，目前只能想到重写 reloadData，而重写 reloadData 一定会这样）
         */
        [self layoutIfNeeded];
    }
    // 不能移动到上面，因为在 view 还没有展示出来时就调用 networkerror 的展示，调用到上面 [self layoutIfNeeded]; 时，会调用 tableview 的 reloadData，reloadData 发现没有 rows，又会调用 emptyView 的展示，会造成两个提示页面重叠的问题
    [self hideEmptyDataNoticeView];
    emptyView.hidden = NO;
}

- (void)hideEmptyDataNoticeView {
    self.emptyProperties.emptyView.hidden = YES;
    self.networkProperties.emptyView.hidden = YES;
}

- (YJScrollEmptyProperties *)emptyProperties {
    return objc_getAssociatedObject(self, &kScrollEmptyProperties);
}

- (void)setEmptyProperties:(YJScrollEmptyProperties *)properties {
    objc_setAssociatedObject(self, &kScrollEmptyProperties, properties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YJScrollEmptyProperties *)networkProperties {
    return objc_getAssociatedObject(self, &kScrollNetworkProperties);
}

- (void)setNetworkProperties:(YJScrollEmptyProperties *)networkProperties {
    objc_setAssociatedObject(self, &kScrollNetworkProperties, networkProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isEnableEmptyDataView {
    return self.emptyProperties != nil;
}

- (void)customEmptyViewPosition:(void(^)(MASConstraintMaker *))block {
    self.emptyProperties.customPositionBlock = block;
    if (block == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.emptyProperties.emptyView != nil) {
            [self.emptyProperties.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                block(make);
            }];
        }
        if (self.networkProperties.emptyView != nil) {
            [self.networkProperties.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                block(make);
            }];
        }
    });
}

@end

@implementation YJScrollEmptyProperties

@end

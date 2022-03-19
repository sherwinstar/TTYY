//
//  UITableView+YJEmptyData.m
//  YouShaQi
//
//  Created by Beginner on 2020/5/13.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "UITableView+YJEmptyData.h"
#import "UIScrollView+YJEmptyData.h"
#import <objc/runtime.h>

@implementation UITableView(YJEmptyData)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        SEL originalSel = @selector(reloadData);
        SEL swizzlingSel = @selector(yj_reloadData);
        Method originM = class_getInstanceMethod(cls, originalSel);
        Method swizzlM = class_getInstanceMethod(cls, swizzlingSel);
        
        BOOL didAddMethod = class_addMethod(cls, originalSel, method_getImplementation(swizzlM), method_getTypeEncoding(swizzlM));
        if (didAddMethod) {
            class_replaceMethod(cls, originalSel, method_getImplementation(originM), method_getTypeEncoding(originM));
        } else {
            method_exchangeImplementations(originM, swizzlM);
        }
    });
}

- (void)yj_reloadData {
    [self yj_reloadData];
    
    if (self.isEnableEmptyDataView) {
        if ([self visibleCells].count == 0) {
            [self showEmptyDataNoticeView];
        } else {
            [self hideEmptyDataNoticeView];
        }
    }
}

@end

//
//  ViewUtils.h
//  WitWenZhou
//
//  Created by carlos on 13-3-22.
//  Copyright (c) 2013年 carlosk. All rights reserved.
//

#import <UIKit/UIKit.h>

DEPRECATED_MSG_ATTRIBUTE("use: YJSToast")
@interface ViewUtils : NSObject

//显示吐司
+ (void)showToast:(NSString *)toast;
+ (void)showToast:(NSString *)toast dismissBlock:(void(^)(void))dismissBlock;
+ (void)showToast:(NSString *)toast delay:(CGFloat)delay dismissBlock:(void(^)(void))dismissBlock;
+ (void)showToast:(NSString *)toast delay:(CGFloat)delay;
+ (void)showToast:(NSString *)toast heightToTop:(NSInteger)heightToTop;

@end

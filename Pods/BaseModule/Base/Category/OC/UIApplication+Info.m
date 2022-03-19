//
//  UIApplication+Info.m
//  BaseModule
//
//  Created by Admin on 2020/10/14.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "UIApplication+Info.h"
#import "NSString+YJ.h"
#import "BaseModule/BaseModule-Swift.h"

@implementation UIApplication (Info)

+ (NSString *)bundleId {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
}

// 版本号：2.26.0
+ (NSString *)versionShortCode {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
// 没有点号的版本号：20260000
+ (NSString *)versionShortCodeWithoutDot {
    NSArray *subs = [[self versionShortCode] componentsSeparatedByString:@"."];
    int result = 0;
    if (subs.count == 3) {
        result = result + [subs[0] intValue] * 1000 * 1000 +  [subs[1] intValue] * 1000 + [subs[2] intValue];
    }
    return [NSString stringWithFormat:@"%d",result];
}

// 带一个点的版本号(新广告接口)
+ (NSString *)versionShortCodeHasOneDot {
    NSArray *tmpArray = [[self versionShortCode] componentsSeparatedByString:@"."];
    NSString *result = @"";
    int count = 0;
    while (count < tmpArray.count) {
        if (!count) {
            result = [NSString stringWithFormat:@"%@.",tmpArray[count]];
        }else{
            NSString *shortVersion = tmpArray[count];
            if (shortVersion.length == 1) {
                shortVersion = [NSString stringWithFormat:@"00%@",shortVersion];
            }else if(shortVersion.length == 2){
                shortVersion = [NSString stringWithFormat:@"0%@",shortVersion];
            }
            result = [NSString stringWithFormat:@"%@%@",result,shortVersion];
        }
        count++;
    }
    return result;
}

+ (NSString *)bookApiPackageName {
    return [self bundleId];
}

+ (nullable NSString *)publisherID {
    NSString *version = [self versionShortCode];
    NSData *data = [version dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [[data base64EncodedStringWithOptions:0] MD5];
    return result;
}

@end

@implementation UIApplication (ViewHierarchy)

+ (UIViewController *)getCurrentVC {
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    UIViewController *appRootVC = appDelegate.window.rootViewController;
    return [self getCurrentVC:appRootVC];
}

+ (UIViewController *)getCurrentVC:(UIViewController *)rootVC {
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        return [self getCurrentVC:tabBarVC.selectedViewController];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootVC;
        return [self getCurrentVC:nav.viewControllers.lastObject];
    } else if ([rootVC respondsToSelector:@selector(selectedViewController)]) {
        UIViewController *child = [(id<YJContainerControllerProtocol>)rootVC selectedViewController];
        if (child != nil) {
            return [self getCurrentVC:child];
        } else {
            return rootVC;
        }
    } else {
        return rootVC;
    }
}

@end

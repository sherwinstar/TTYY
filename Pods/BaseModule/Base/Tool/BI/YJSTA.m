//
//  YJSTA.m
//  BaseApp
//
//  Created by Admin on 2020/7/16.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "YJSTA.h"
#import "SensorsAnalyticsSDK.h"

@implementation YJSTA

+ (void)setUserProfile:(id)profile forKey:(NSString *)key {
    [[SensorsAnalyticsSDK sharedInstance] set:key to:profile];
}

+ (void)trackWithEventName:(NSString *)eventName properties:(NSDictionary *)properties {
    if (eventName.length && properties) {
        [[SensorsAnalyticsSDK sharedInstance] track:eventName withProperties:properties];
    }
}

+ (void)trackViewScreen:(UIViewController *)vc withProperties:(NSDictionary *)properties {
    if (vc && properties) {
        [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:vc properties:properties];
    }
}

+ (void)trackViewAppClick:(UIView *)view withProperties:(NSDictionary *)properties {
    if (view && properties) {
        [[SensorsAnalyticsSDK sharedInstance] trackViewAppClick:view withProperties:properties];
    }
}

+ (void)ignoreAutoTrackViewControllers:(NSArray<UIViewController *> *)vcs {
    NSMutableArray *vcNames = [[NSMutableArray alloc] initWithCapacity:0];
    for (UIViewController *vc in vcs) {
        [vcNames addObject:NSStringFromClass([vc class])];
    }
    [[SensorsAnalyticsSDK sharedInstance] ignoreAutoTrackViewControllers:vcNames];
}

@end

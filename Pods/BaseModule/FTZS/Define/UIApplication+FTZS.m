//
//  UIApplication+FTZS.m
//  BaseModule
//
//  Created by Admin on 2020/10/14.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "UIApplication+FTZS.h"

@implementation UIApplication (FTZS)

+ (NSString *)appName {
    return @"zhuishuFree";
}

+ (NSString *)packageName {
    return @"com.ifmoc.DouKouYueDu2";
}

+ (NSString *)platformType {
    return @"zhuishuFree";
}

/// 产品线
+ (NSString *)productLine {
    // 1追书 2漫画岛 3开卷 4免费阅读广告(破解版) 5芒果阅读 6追书免费版（独立包）10饭团追书
#ifdef TARGET_TTYY
    return @"26";
#endif
    return @"10";
}

+ (NSString *)h5Version {
    return @"7";
}

+ (NSString *)userLoginChannel {
    return @"zhuishuFanTuaniOS";
}

@end

//
//  ThirdLoginStorage.m
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/17.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import "ThirdLoginStorage.h"

@implementation ThirdLoginStorage

+ (instancetype)sharedStorage {
    static dispatch_once_t onceToken;
    static ThirdLoginStorage *storage = nil;
    dispatch_once(&onceToken, ^{
        storage = [[ThirdLoginStorage alloc] init];
    });
    return storage;
}

- (BOOL)isAuthorizeValidate:(SSDKPlatformType)type {
    if (type == SSDKPlatformTypeSinaWeibo) {
        if (!self.weiboUser) {
            return NO;
        }
        if (!self.weiboUser.credential.expired) {
            return NO;
        }
        
        if ([[NSDate date] timeIntervalSinceDate:self.weiboUser.credential.expired] > 0) {
            return NO;
        }
        return YES;
    } else if (type == SSDKPlatformTypeSS) {
        if (!self.wechatUser) {
            return NO;
        }
        if ([[NSDate date] timeIntervalSinceDate:self.wechatUser.credential.expired] > 0) {
            return NO;
        }
        return YES;
    } else if (type == SSDKPlatformTypeQQ) {
        if (!self.QQUser) {
            return NO;
        }
        if ([[NSDate date] timeIntervalSinceDate:self.QQUser.credential.expired] > 0) {
            return NO;
        }
        return YES;
    }
    return NO;
    
}
@end

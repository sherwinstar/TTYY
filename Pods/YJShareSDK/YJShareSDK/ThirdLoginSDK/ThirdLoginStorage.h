//
//  ThirdLoginStorage.h
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/17.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDKTypeDefine.h"
#import "SSDKUser.h"

@interface ThirdLoginStorage : NSObject

+ (instancetype)sharedStorage;
//判断平台授权当前是否有效
- (BOOL)isAuthorizeValidate:(SSDKPlatformType)type;

@property (nonatomic, strong) NSString *weiboAppId;//新浪微博appid
@property (nonatomic, strong) NSString *weiboRedirectURI;//新浪微博redirectURI
@property (nonatomic, strong) SSDKUser *weiboUser;

@property (nonatomic, strong) NSString *wechatAppid;//微信appid
@property (nonatomic, strong) NSString *wechatAppSecret;//微信appSecret
@property (nonatomic, strong) SSDKUser *wechatUser;//微信用户

@property (nonatomic, strong) NSString *QQAppid;//QQappid
@property (nonatomic, strong) NSString *QQAppRedirectURI;//QQappSecret
@property (nonatomic, strong) NSString *QQAppUniversalLink;//universalLink
@property (nonatomic, strong) SSDKUser *QQUser;//QQ用户
@property (nonatomic, strong) id tencentOAuth;

@property (nonatomic, copy) SSDKAuthorizeStateChangedHandler authorieChangeHander;
@property (nonatomic, copy) SSDKShareStateChangedHandler shareChangeHander;

@end

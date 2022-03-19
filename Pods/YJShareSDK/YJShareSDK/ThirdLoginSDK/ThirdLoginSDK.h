//
//  ThirdLoginSDK.h
//  ThirdLoginSDK
//
//  Created by wangbc on 16/8/18.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSDKUser.h"
#import "SSDKCredential.h"
#import "NSMutableDictionary+ShareParams.h"

@interface ThirdLoginSDK : NSObject

#pragma mark - handle open url
+ (void)handleOpenURL:(NSURL *)url;
+ (BOOL)handleWxOpenUniversalLink:(NSUserActivity *)userActivity;
+ (BOOL)handleQQOpenUniversalLink:(NSUserActivity *)userActivity;
#pragma mark - 初始化配置
/**
 *  设置新浪微博应用信息
 *
 *  @param appKey       应用标识
 *  @param appSecret    应用密钥
 *  @param redirectUri  回调地址
 */
+ (void)SSDKSetupSinaWeiboByAppKey:(NSString *)appKey
                         appSecret:(NSString *)appSecret
                       redirectUri:(NSString *)redirectUri;
/**
 *  设置微信(微信好友，微信朋友圈、微信收藏)应用信息
 *
 *  @param appId      应用标识
 *  @param appSecret  应用密钥
 *  @param universalLink 长链接地址
 *
 *  饭团是：https://th5.zhuishushenqi.com/ftzs/wechat/
 *  追书是：https://th5.zhuishushenqi.com/zssq/wechat/
 */
+ (void)SSDKSetupWeChatByAppId:(NSString *)appId
                     appSecret:(NSString *)appSecret
                 universalLink:(NSString *)universalLink;

/**
 *  设置QQ应用信息
 *
 *  @param appId      应用标识
 *  @param appSecret  应用密钥
 *  @param universalLink 长链接地址
 */
+ (void)SSDKSetupQQByAppId:(NSString *)appId
               redirectUri:(NSString *)redirectUri
             universalLink:(NSString *)universalLink;

#pragma mark - 第三方授权&登陆
/**
 *  平台授权
 *
 *  @param platformType       平台类型
 *  @param @param settings    授权设置,目前只接受SSDKAuthSettingKeyScopes属性设置，如新浪微博关注官方微博：@{SSDKAuthSettingKeyScopes : @[@"follow_app_official_microblog"]}，类似“follow_app_official_microblog”这些字段是各个社交平台提供的。
 *  @param stateChangeHandler 授权状态变更回调处理
 */
+ (void)authorize:(SSDKPlatformType)platformType
         settings:(NSDictionary *)settings
   onStateChanged:(SSDKAuthorizeStateChangedHandler)stateChangedHandler;

/**
 *  获取授权用户信息
 *
 *  @param platformType       平台类型
 *  @param stateChangeHandler 状态变更回调处理
 */
+ (void)getUserInfo:(SSDKPlatformType)platformType
     onStateChanged:(SSDKGetUserStateChangedHandler)stateChangedHandler;

#pragma mark - 分享
/**
 *  分享内容
 *
 *  @param platformType             平台类型
 *  @param parameters               分享参数
 *  @param stateChangeHandler       状态变更回调处理
 */
+ (void)share:(SSDKShareType)platformType
   parameters:(NSMutableDictionary *)parameters
onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler;

+ (NSData *)imageDataWithImage:(UIImage *)image fixedLength:(NSInteger)byte;

@end



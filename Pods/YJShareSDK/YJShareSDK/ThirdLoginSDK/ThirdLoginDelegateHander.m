//
//  ThirdLoginDelegateHander.m
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/17.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import "ThirdLoginDelegateHander.h"
#import "SSDKTypeDefine.h"
#import "ThirdLoginStorage.h"
#import "SSDKCredential.h"
#import "SSDKUser.h"
#import "NetworkHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>

@implementation ThirdLoginDelegateHander

+ (instancetype)sharedInstance {
    static ThirdLoginDelegateHander *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ThirdLoginDelegateHander alloc] init];
    });
    return instance;
}


#pragma mark -  QQSDKDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin{
    NSLog(@"QQ登录成功");
    SSDKUser *qqUser = [[SSDKUser alloc] init];
    id tencentOAuth = [ThirdLoginStorage sharedStorage].tencentOAuth;
    
    SSDKCredential *credential = [[SSDKCredential alloc] init];
    credential.token = [tencentOAuth valueForKey:@"accessToken"];
    credential.expired = [tencentOAuth valueForKey:@"expirationDate"];
    credential.rawData = [tencentOAuth valueForKey:@"passData"];
    credential.uid = [tencentOAuth valueForKey:@"openId"];
    qqUser.credential = credential;
    qqUser.uid = [tencentOAuth valueForKey:@"openId"];
    qqUser.platformType = SSDKPlatformTypeQQ;

    [ThirdLoginStorage sharedStorage].QQUser = qqUser;
    
    SSDKAuthorizeStateChangedHandler block = [ThirdLoginStorage sharedStorage].authorieChangeHander;
    if (block) {
        block(SSDKResponseStateSuccess,qqUser,nil);
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"QQ登录失败");
    SSDKAuthorizeStateChangedHandler block = [ThirdLoginStorage sharedStorage].authorieChangeHander;
    if (block) {
        block(SSDKResponseStateFail,nil,nil);
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork{
    NSLog(@"QQ登录时网络异常");
    SSDKAuthorizeStateChangedHandler block = [ThirdLoginStorage sharedStorage].authorieChangeHander;
    if (block) {
        block(SSDKResponseStateFail,nil,nil);
    }
}

/**
 * 登录时权限信息的获得
 */
- (NSArray *)getAuthorizedPermissions:(NSArray *)permissions withExtraParams:(NSDictionary *)extraParams {
    NSLog(@"QQ登录成功获取的权限：%@",permissions);
    NSLog(@"QQ登录成功获取的授权信息：%@",extraParams);
    return nil;
}

/**
 * 获取用户信息成功后会调用这个傻逼方法
 */
-(void)getUserInfoResponse:(APIResponse *)response {
    
    SSDKAuthorizeStateChangedHandler block = [ThirdLoginStorage sharedStorage].authorieChangeHander;
    
    if (response.errorMsg) {
        if (block) {
            block(SSDKResponseStateFail,nil,[NSError errorWithDomain:response.errorMsg code:1234 userInfo:nil]);
        }
        return;
    }
    
    //response.jsonResponse  :
//    city = "";
//    figureurl = "http://qzapp.qlogo.cn/qzapp/100573263/3B836E6A0292C8819B77D652B8C88F3D/30";
//    "figureurl_1" = "http://qzapp.qlogo.cn/qzapp/100573263/3B836E6A0292C8819B77D652B8C88F3D/50";
//    "figureurl_2" = "http://qzapp.qlogo.cn/qzapp/100573263/3B836E6A0292C8819B77D652B8C88F3D/100";
//    "figureurl_qq_1" = "http://q.qlogo.cn/qqapp/100573263/3B836E6A0292C8819B77D652B8C88F3D/40";
//    "figureurl_qq_2" = "http://q.qlogo.cn/qqapp/100573263/3B836E6A0292C8819B77D652B8C88F3D/100";
//    gender = "\U7537";
//    "is_lost" = 0;
//    "is_yellow_vip" = 0;
//    "is_yellow_year_vip" = 0;
//    level = 0;
//    msg = "";
//    nickname = "\Uff1a";
//    province = "";
//    ret = 0;
//    vip = 0;
//    "yellow_vip_level" = 0;
    
    NSDictionary *resp = response.jsonResponse;
    SSDKUser *qqUser = [ThirdLoginStorage sharedStorage].QQUser;
    qqUser.nickname = [resp objectForKey:@"nickname"];
    NSString *g = [resp objectForKey:@"gender"];
    if ([g isEqualToString:@"男"]) {
        qqUser.gender = SSDKGenderMale;
    } else {
        qqUser.gender = SSDKGenderFemale;
    }
    qqUser.icon = [resp objectForKey:@"figureurl_qq_2"];
    

    if (block) {
        block(SSDKResponseStateSuccess,qqUser,nil);
    }
}


- (void)qqShareResponse:(id)resp {
    int errCode = [[resp valueForKey:@"result"] intValue];
    if (errCode == 0) {
        //成功
        if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
            [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateSuccess,nil,nil);
        }
    } else if (errCode == -4) {
        //取消
        if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
            [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateCancel,nil,nil);
        }
    } else {
        if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[resp valueForKey:@"result"] forKey:@"result"];
            [userInfo setValue:[resp valueForKey:@"errorDescription"] forKey:@"errorDescription"];
            [userInfo setValue:[resp valueForKey:@"extendInfo"] forKey:@"extendInfo"];
            [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateFail,userInfo,nil);
        }
    }
    [ThirdLoginStorage sharedStorage].shareChangeHander = nil;
}

#pragma mark -  WeiboSDKDelegate

/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(id)request {
    //WBBaseRequest *request
    NSLog(@"");
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(id)response {
    //WBBaseResponse *response
    if ([response isKindOfClass:NSClassFromString(@"WBAuthorizeResponse")]) {
        //授权接口
        NSNumber *statusCode = [response valueForKey:@"statusCode"];
       
        if ([statusCode isEqual:@(0)]) {
            //成功
            SSDKCredential *credential = [[SSDKCredential alloc] init];
            credential.uid = [response valueForKey:@"userID"];
            credential.token = [response valueForKey:@"accessToken"];
            credential.expired = [response valueForKey:@"expirationDate"];
            credential.rawData = [response valueForKey:@"requestUserInfo"];
            
            SSDKUser *user = [[SSDKUser alloc] init];
            user.platformType = SSDKPlatformTypeSinaWeibo;
            user.uid = credential.uid;
            user.credential = credential;
            [ThirdLoginStorage sharedStorage].weiboUser = user;
            if ([ThirdLoginStorage sharedStorage].authorieChangeHander) {
                [ThirdLoginStorage sharedStorage].authorieChangeHander(SSDKResponseStateSuccess,user,nil);
                [ThirdLoginStorage sharedStorage].authorieChangeHander = nil;
            }
        } else if ([statusCode isEqual:@(-1)]) {
            //取消
            if ([ThirdLoginStorage sharedStorage].authorieChangeHander) {
                [ThirdLoginStorage sharedStorage].authorieChangeHander(SSDKResponseStateCancel,nil,nil);
                [ThirdLoginStorage sharedStorage].authorieChangeHander = nil;
            }
        } else {
            //错误
            NSDictionary *info = [response valueForKey:@"requestUserInfo"];
            NSError *err = [NSError errorWithDomain:@"WeiboLoginError" code:statusCode.integerValue userInfo:info];
            if ([ThirdLoginStorage sharedStorage].authorieChangeHander) {
                [ThirdLoginStorage sharedStorage].authorieChangeHander(SSDKResponseStateFail,nil,err);
                [ThirdLoginStorage sharedStorage].authorieChangeHander = nil;
            }
        }
    } else if ([response isKindOfClass:NSClassFromString(@"WBSendMessageToWeiboResponse")]) {
        //微博分享结果
        NSNumber *statusCode = [response valueForKey:@"statusCode"];
        if ([statusCode isEqual:@(0)]) {
            //成功
            if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
                [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateSuccess,nil,nil);
            }
        } else {
            if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
                [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateFail,[response valueForKey:@"requestUserInfo"],nil);
            }
        }
    }
    NSLog(@"");
}

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(id)req {
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(id)resp {
    if ([resp isMemberOfClass:NSClassFromString(@"SendAuthResp")]) {
        [self weixinAuthResponse:resp];
    } else if ([resp isMemberOfClass:NSClassFromString(@"SendMessageToWXResp")]) {
        [self weixinShareResponse:resp];
    } else if ([resp isMemberOfClass:NSClassFromString(@"SendMessageToQQResp")]) {
        //qq分享
        [self qqShareResponse:resp];
    }
    
}

- (void)weixinAuthResponse:(id)resp {
    NSInteger errCode = [[resp valueForKey:@"errCode"] integerValue];
    switch (errCode) {
        case 0: {//WXSuccess
            NSString *appid = [ThirdLoginStorage sharedStorage].wechatAppid;
            NSString *appsecret = [ThirdLoginStorage sharedStorage].wechatAppSecret;
            NSString *urlForToken = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", appid, appsecret,[resp valueForKey:@"code"]];
            [NetworkHelper requestWithUrl:urlForToken completeBlock:^(NSDictionary *tokenJson, NSError *errorForToken) {
                //                {
                //                    "access_token" = "EKXPQ0RcPsQRTimsZLuN0-0dolz7ebbSrTVZLP7Hb5vsk-iY7XNoKO_uIJUgcuox1nyd3tvuNUTc4zbLrNWE16c2kzAkUX7K_QLAViu6oqs";
                //                    "expires_in" = 7200;
                //                    openid = "odE4CuFUI_rwJwfjX16PP-2Ok7o8";//openid只是相对当前公众号唯一
                //                    "refresh_token" = "b-1huAiq-drAA3qFrCDFqfSjfMNENMNFGrowlRUItsLKDUtfEoODJohgzI3l1dbKSeZJ7P0qDeQTrJpXRFNK056eYDcQJ4lV9cAJi1SriLM";
                //                    scope = "snsapi_userinfo";
                //                    unionid = "o3AmWjo2AcYuMZqkG0P-i1qfxm2Y";//unionid是相对用户唯一
                //                }
                NSString *token = [tokenJson valueForKey:@"access_token"];
                if (!token.length) {
                    //获取token失败
                    if ([ThirdLoginStorage sharedStorage].authorieChangeHander) {
                        [ThirdLoginStorage sharedStorage].authorieChangeHander(SSDKResponseStateFail,nil,errorForToken);
                    }
                    [ThirdLoginStorage sharedStorage].authorieChangeHander = nil;
                    return;
                } else {
                    //成功
                    SSDKCredential *credential = [[SSDKCredential alloc] init];
                    credential.uid  = [tokenJson valueForKey:@"openid"];
                    credential.token = token;
                    credential.rawData = tokenJson;
                    credential.expired = [NSDate dateWithTimeIntervalSinceNow:[[tokenJson valueForKey:@"expires_in"] integerValue]];
                    SSDKUser *user = [[ SSDKUser alloc] init];
                    user.credential = credential;
                    user.uid = credential.uid;
                    [ThirdLoginStorage sharedStorage].wechatUser = user;
                    if ([ThirdLoginStorage sharedStorage].authorieChangeHander) {
                        [ThirdLoginStorage sharedStorage].authorieChangeHander(SSDKResponseStateSuccess,user,nil);
                    }
                }
            }];
        }
            break;
            
        case -1:
        case -2:
        case -3:
        case -4:
        case -5: {
            NSError *customError = [NSError errorWithDomain:@"微信授权失败" code:errCode userInfo:@{@"resp":resp}];
            if ([ThirdLoginStorage sharedStorage].authorieChangeHander) {
                [ThirdLoginStorage sharedStorage].authorieChangeHander(SSDKResponseStateFail,nil,customError);
            }
            [ThirdLoginStorage sharedStorage].authorieChangeHander = nil;
            return;
        }
            break;
        default:
            break;
    }
}

- (void)weixinShareResponse:(id)resp {
    int errCode = [[resp valueForKey:@"errCode"] intValue];
    if (errCode == 0) {
        //成功
        if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
            [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateSuccess,nil,nil);
        }
    } else if (errCode == -2) {
        //取消
        if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
            [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateCancel,nil,nil);
        }
    } else {
        if ([ThirdLoginStorage sharedStorage].shareChangeHander) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[resp valueForKey:@"errCode"] forKey:@"errCode"];
            [userInfo setValue:[resp valueForKey:@"type"] forKey:@"type"];
            [userInfo setValue:[resp valueForKey:@"errStr"] forKey:@"errStr"];
            [ThirdLoginStorage sharedStorage].shareChangeHander(SSDKResponseStateFail,userInfo,nil);
        }
    }
    [ThirdLoginStorage sharedStorage].shareChangeHander = nil;
}

@end

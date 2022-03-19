//
//  ThirdLoginSDK.m
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/17.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import "ThirdLoginStorage.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ThirdLoginDelegateHander.h"
#import "NetworkHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "ThirdLoginSDK.h"

@implementation ThirdLoginSDK 

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"

#pragma mark - handle open url
+ (void)handleOpenURL:(NSURL *)url {
    NSString *urlStr = url.absoluteString;
    NSString *weiboStr = [NSString stringWithFormat:@"wb%@",[ThirdLoginStorage sharedStorage].weiboAppId];
    if ([urlStr rangeOfString:weiboStr].location != NSNotFound) {
        //微博
        [NSClassFromString(@"WeiboSDK") performSelector:@selector(handleOpenURL:delegate:) withObject:url withObject:[ThirdLoginDelegateHander sharedInstance]];
    }
    if ([urlStr hasPrefix:[ThirdLoginStorage sharedStorage].wechatAppid]) {
        //微信
        [NSClassFromString(@"WXApi") performSelector:@selector(handleOpenURL:delegate:) withObject:url withObject:[ThirdLoginDelegateHander sharedInstance]];
    }
    if ([urlStr hasPrefix:@"QQ"] || [urlStr hasPrefix:@"tencent"]) {
        //QQ登陆
        if ([urlStr rangeOfString:@"qzapp/mqzone"].location != NSNotFound) {
            [NSClassFromString(@"TencentOAuth") performSelector:@selector(HandleOpenURL:) withObject:url];
        } else if ([urlStr rangeOfString:@"response_from_qq"].location != NSNotFound) {
            //qq分享
            [NSClassFromString(@"QQApiInterface") performSelector:@selector(handleOpenURL:delegate:) withObject:url withObject:[ThirdLoginDelegateHander sharedInstance]];
        }
    }
    NSLog(@"------------%@",url);
}

+ (BOOL)handleWxOpenUniversalLink:(NSUserActivity *)userActivity {
    return [NSClassFromString(@"WXApi") performSelector:@selector(handleOpenUniversalLink:delegate:) withObject:userActivity withObject:[ThirdLoginDelegateHander sharedInstance]];
}

+ (BOOL)handleQQOpenUniversalLink:(NSUserActivity *)userActivity {
    return [NSClassFromString(@"TencentOAuth") performSelector:@selector(HandleUniversalLink:) withObject:userActivity.webpageURL.absoluteURL];
}

#pragma mark - 初始化配置
/**
 *  设置新浪微博应用信息
 *
 *  @param appKey       应用标识
 *  @param appSecret    应用密钥
 *  @param redirectUri  回调地址
 */
+ (void)SSDKSetupSinaWeiboByAppKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectUri:(NSString *)redirectUri {
    Class weiboSDK = NSClassFromString(@"WeiboSDK");
    if (!weiboSDK) {
        NSLog(@"未集成新浪微博SDK");
    }

    [weiboSDK performSelector:@selector(registerApp:) withObject:appKey];

//    [weiboSDK registerApp:appKey];
    [ThirdLoginStorage sharedStorage].weiboAppId = appKey;
    [ThirdLoginStorage sharedStorage].weiboRedirectURI = redirectUri;
}
/**
 *  设置微信(微信好友，微信朋友圈、微信收藏)应用信息
 *
 *  @param appId      应用标识
 *  @param appSecret  应用密钥
 */
+ (void)SSDKSetupWeChatByAppId:(NSString *)appId
                     appSecret:(NSString *)appSecret
                 universalLink:(NSString *)universalLink {
    Class weixinApi = NSClassFromString(@"WXApi");
    if (!weixinApi) {
        NSLog(@"微信SDK尚未集成");
        return;
    }
    [ThirdLoginStorage sharedStorage].wechatAppid = appId;
    [ThirdLoginStorage sharedStorage].wechatAppSecret = appSecret;
    [weixinApi performSelector:@selector(registerApp:universalLink:) withObject:appId withObject:universalLink];
}

/**
 *  设置QQ应用信息b
 *
 *  @param appId      应用标识
 *  @param appSecret  应用密钥
 */
+ (void)SSDKSetupQQByAppId:(NSString *)appId
               redirectUri:(NSString *)redirectUri
             universalLink:(NSString *)universalLink {
    Class qqSDK = NSClassFromString(@"TencentOAuth");
    if (!qqSDK) {
        NSLog(@"qqSDK尚未集成");
        return;
    }
    [ThirdLoginStorage sharedStorage].QQAppid = appId;
    [ThirdLoginStorage sharedStorage].QQAppRedirectURI = redirectUri;
    [ThirdLoginStorage sharedStorage].QQAppUniversalLink = universalLink;
}


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
   onStateChanged:(SSDKAuthorizeStateChangedHandler)stateChangedHandler {
    if (platformType == SSDKPlatformTypeSinaWeibo) {
        //新浪微博
        [self sinaWeiboAuthWithChangedHandler:stateChangedHandler];
    } else if (platformType == SSDKPlatformTypeSS) {
        [self weixinAuthWithChangedHandler:stateChangedHandler];
    } else if (platformType == SSDKPlatformTypeQQ) {
        [self QQAuthWithChangedHandler:stateChangedHandler];
    }
}

/**
 *  获取授权用户信息
 *
 *  @param platformType       平台类型
 *  @param stateChangeHandler 状态变更回调处理
 */
+ (void)getUserInfo:(SSDKPlatformType)platformType
     onStateChanged:(SSDKGetUserStateChangedHandler)stateChangedHandler {
    if (![[ThirdLoginStorage sharedStorage] isAuthorizeValidate:platformType]) {
        //如果没有授权，先去授权
        [self authorize:platformType settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
            if (state == SSDKResponseStateSuccess) {
                [self getUserInfo:platformType onStateChanged:stateChangedHandler];
            } else {
                if (stateChangedHandler) {
                    stateChangedHandler(state,user,error);
                }
            }
        }];
        return;
    }
    
    if (platformType == SSDKPlatformTypeSinaWeibo) {
        [self sinaWeiboGetUserInfoWithChangedHandler:stateChangedHandler];
        
    } else if (platformType == SSDKPlatformTypeSS) {
        [self weixinGetUserInfoWithChangedHandler:stateChangedHandler];
    } else if (platformType == SSDKPlatformTypeQQ) {
        [self qqGetUserInfoWithChangedHandler:stateChangedHandler];
    }
}

#pragma mark - 分享
/**
 *  分享内容
 *
 *  @param platformType             平台类型
 *  @param parameters               分享参数
 *  @param stateChangeHandler       状态变更回调处理
 */
+ (void)share:(SSDKShareType)shareType
   parameters:(NSMutableDictionary *)parameters
onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler {
    //标题：title，内容：content，链接url：url，图片：image
    
    if (shareType == SSDKShareTypeSinaWeibo) {
        [self sinaWeiboShareWithparameters:parameters onStateChanged:stateChangedHandler];
    } else if (shareType == SSDKShareTypeSSTimeLine || shareType == SSDKShareTypeSSFriend) {
        [self weixinShareWithType:shareType parameters:parameters onStateChanged:stateChangedHandler];
        
    } else if (shareType == SSDKShareTypeQQFriend || shareType == SSDKShareTypeQZone) {
        SSDKContentType type = [[parameters valueForKey:@"type"] integerValue];
        if (type == SSDKContentTypeImage) {
            [self qqImageShareWithparameters:parameters onStateChanged:stateChangedHandler shareType:shareType];
        } else if (type == SSDKContentTypeWebPage) {
            [self qqLinkShareWithparameters:parameters onStateChanged:stateChangedHandler shareType:shareType];
        }
    }
}

#pragma mark - private QQ
//QQ 授权登录
+ (void)QQAuthWithChangedHandler:(SSDKAuthorizeStateChangedHandler)changeHander {
    Class sendAuthReq = NSClassFromString(@"TencentOAuth");
    if (!sendAuthReq) {
        changeHander(SSDKResponseStateFail,nil,nil);
        return;
    }
    [ThirdLoginStorage sharedStorage].authorieChangeHander = changeHander;
    NSArray *permissions = @[@"get_user_info",
                             @"get_simple_userinfo",
                             @"add_share"];
    
    [self checkQQInit];

    [[ThirdLoginStorage sharedStorage].tencentOAuth authorize:permissions];
}

//获取QQ用户信息
+ (void)qqGetUserInfoWithChangedHandler:(SSDKGetUserStateChangedHandler)changeHander {
    [ThirdLoginStorage sharedStorage].authorieChangeHander = changeHander;
    [[ThirdLoginStorage sharedStorage].tencentOAuth getUserInfo];
}

//QQ分享 － 链接
+ (void)qqLinkShareWithparameters:(NSMutableDictionary *)parameters
                   onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler
                        shareType:(SSDKShareType)shareType
{
    if (![NSClassFromString(@"QQApiInterface") performSelector:@selector(isQQInstalled)]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您未安装QQ客户端，请选择其他分享方式"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    [self checkQQInit];
    [ThirdLoginStorage sharedStorage].shareChangeHander = stateChangedHandler;
    
    NSString *shareTitle = parameters[@"title"];
    NSString *shareContent = parameters[@"content"];
    NSURL *shareLink = parameters[@"url"];
    id shareImage = parameters[@"image"];
    shareImage = [self loadImage:shareImage];
    if (!shareImage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"无法获取分享图片"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSData *imageData;
    NSURL *imageURL;
    
    id imgObj;
    if ([shareImage isKindOfClass:[UIImage class]]) {
        imageData = [self imageDataWithImage:shareImage fixedLength:32 * 1024];
        if (!imageData) {
            shareImage = UIImagePNGRepresentation([UIImage imageNamed:@"Icon_120@2x"]);
        }
        SEL selector = @selector(objectWithURL: title: description: previewImageData:);
        imgObj = ((id (*)(id, SEL, id,id,id,id)) objc_msgSend)(NSClassFromString(@"QQApiNewsObject"), selector,shareLink,shareTitle,shareContent,imageData);
    } else if ([shareImage isKindOfClass:[NSURL class]]) {
        imageURL = shareImage;
        SEL selector = @selector(objectWithURL: title: description: previewImageURL:);
        imgObj = ((id (*)(id, SEL, id,id,id,id)) objc_msgSend)(NSClassFromString(@"QQApiNewsObject"), selector,shareLink,shareTitle,shareContent,imageURL);
    }
    
    id req = ((id (*)(id, SEL, id)) objc_msgSend)(NSClassFromString(@"SendMessageToQQReq"),  @selector(reqWithContent:),imgObj);
    SEL sendSEL = shareType == SSDKShareTypeQQFriend ? @selector(sendReq:) : @selector(SendReqToQZone:);
    ((void(*)(id, SEL,id))objc_msgSend)(NSClassFromString(@"QQApiInterface"), sendSEL,req);
}

//QQ分享 － 图片
+ (void)qqImageShareWithparameters:(NSMutableDictionary *)parameters
                       onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler
                            shareType:(SSDKShareType)shareType
{
    if (![NSClassFromString(@"QQApiInterface") performSelector:@selector(isQQInstalled)]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您未安装QQ客户端，请选择其他分享方式"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    [self checkQQInit];
    [ThirdLoginStorage sharedStorage].shareChangeHander = stateChangedHandler;
    
    NSString *shareTitle = parameters[@"title"];
    NSString *shareContent = parameters[@"content"];
    UIImage *shareImage = parameters[@"image"];
    shareImage = [self loadImage:shareImage];
    if (!shareImage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"无法获取分享图片"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSData *shareImageData = [self imageDataWithImage:shareImage fixedLength:1024 * 1024 * 5];
    NSData *thumbImageData = [self imageDataWithImage:shareImage fixedLength:1024 * 1024];
    if (!thumbImageData) {
        thumbImageData = UIImagePNGRepresentation([UIImage imageNamed:@"Icon_120@2x"]);
    }
    if (!shareImageData) {
        [self showInvaildImgTip];
        return;
    }
    
    SEL selector = @selector(objectWithData:previewImageData:title:description:);
    id imgObj = ((id (*)(id, SEL, id,id,id,id)) objc_msgSend)(NSClassFromString(@"QQApiImageObject"), selector,shareImageData,thumbImageData,shareTitle,shareContent);
    id req = ((id (*)(id, SEL, id)) objc_msgSend)(NSClassFromString(@"SendMessageToQQReq"),  @selector(reqWithContent:),imgObj);
    SEL sendSEL = shareType == SSDKShareTypeQQFriend ? @selector(sendReq:) : @selector(SendReqToQZone:);
    ((void(*)(id, SEL,id))objc_msgSend)(NSClassFromString(@"QQApiInterface"), sendSEL,req);
}

+ (void) checkQQInit {
    if (![ThirdLoginStorage sharedStorage].tencentOAuth) {
        [ThirdLoginStorage sharedStorage].tencentOAuth = [[NSClassFromString(@"TencentOAuth") alloc] initWithAppId:[ThirdLoginStorage sharedStorage].QQAppid enableUniveralLink:YES universalLink:[ThirdLoginStorage sharedStorage].QQAppUniversalLink delegate:[ThirdLoginDelegateHander sharedInstance]];
    }
}

#pragma mark - private 微信
+ (void)weixinAuthWithChangedHandler:(SSDKAuthorizeStateChangedHandler)changeHander {
    if (![NSClassFromString(@"WXApi") performSelector:@selector(isWXAppInstalled)]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您未安装微信客户端，请选择其他分享方式"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    Class sendAuthReq = NSClassFromString(@"SendAuthReq");
    if (!sendAuthReq) {
        changeHander(SSDKResponseStateFail,nil,nil);
        return;
    }
    [ThirdLoginStorage sharedStorage].authorieChangeHander = changeHander;
    id req = [[sendAuthReq alloc] init];
    [req setValue:@"snsapi_userinfo" forKey:@"scope"];
    [NSClassFromString(@"WXApi") performSelector:@selector(sendReq:completion:) withObject:req withObject:nil];
    
}

+ (void)weixinGetUserInfoWithChangedHandler:(SSDKGetUserStateChangedHandler)changeHander {
    SSDKUser *weixinUser = [ThirdLoginStorage sharedStorage].wechatUser;
    NSString *openid = [weixinUser.credential.rawData valueForKey:@"openid"];
    NSString *accessToken = weixinUser.credential.token;
    NSString *urlForUserInfo = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken,openid];
    [NetworkHelper requestWithUrl:urlForUserInfo completeBlock:^(NSDictionary *userInfoJson, NSError *error) {
        NSString *uid = [userInfoJson valueForKey:@"openid"];
//        {
//            city = "Pudong New District";
//            country = CN;
//            headimgurl = "http://wx.qlogo.cn/mmopen/bSb5dSzPn0KicD3kMibLGCfe3lgLzia5JOZoejibXSvPNhWZZ0AibNI87vO7quNVqJVk0zXf5icydyFsDycxRGeEdUIg/0";
//            language = "zh_CN";
//            nickname = "\U738b\U70b3\U806a";
//            openid = "odE4CuFUI_rwJwfjX16PP-2Ok7o8";
//            privilege =     (
//            );
//            province = Shanghai;
//            sex = 1;//值为1时是男性，值为2时是女性，值为0时是未知
//            unionid = "o3AmWjo2AcYuMZqkG0P-i1qfxm2Y";
//        }
        if (!uid.length) {
            if (changeHander) {
                changeHander(SSDKResponseStateFail,nil,error);
            }
        } else {
            SSDKUser *weixinUser = [ThirdLoginStorage sharedStorage].wechatUser;
            weixinUser.nickname = [userInfoJson valueForKey:@"nickname"];
            weixinUser.icon = [userInfoJson valueForKey:@"headimgurl"];
            if ([[userInfoJson valueForKey:@"sex"] integerValue] == 1) {
                weixinUser.gender = SSDKGenderMale;
            } else if ([[userInfoJson valueForKey:@"sex"] integerValue] == 2) {
                weixinUser.gender = SSDKGenderFemale;
            } else if ([[userInfoJson valueForKey:@"sex"] integerValue] == 0) {
                weixinUser.gender = SSDKGenderUnknown;
            }
        }
        [ThirdLoginStorage sharedStorage].wechatUser = weixinUser;
        if (changeHander) {
            changeHander(SSDKResponseStateSuccess,weixinUser,nil);
        }
        
    }];
}

+ (void)weixinShareWithType:(SSDKShareType)SSDKShareType
                 parameters:(NSMutableDictionary *)parameters
                      onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler {
    if (![NSClassFromString(@"WXApi") performSelector:@selector(isWXAppInstalled)]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您未安装微信客户端，请选择其他分享方式"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    NSString *shareTitle = parameters[@"title"];
    NSString *shareContent = parameters[@"content"];
    NSURL *shareLink = parameters[@"url"];
    id img = parameters[@"image"];
    UIImage *shareImage = [self loadImage:img];
    if (!shareImage) {
        [self showInvaildImgTip];
        return;
    }
    SSDKContentType type = [[parameters valueForKey:@"type"] integerValue];
    int scene = 0; // 聊天界面，朋友圈，收藏
    if (SSDKShareType == SSDKShareTypeSSTimeLine) {
        scene = 1;
    }
    
    // 题目，描述，缩略图等通用内容
    id media = [[NSClassFromString(@"WXMediaMessage") alloc] init];
    [media setValue:shareTitle forKey:@"title"];
    [media setValue:shareContent forKey:@"description"];
    //图片必须在32k以内
    NSData *compressedImgData = [self imageDataWithImage:shareImage fixedLength:32 * 1024];
    if (!compressedImgData) {
        compressedImgData = UIImagePNGRepresentation([UIImage imageNamed:@"Icon_120@2x"]);
    }
    [media setValue:compressedImgData forKey:@"thumbData"];
    
    // Media（不通用）
    if (type == SSDKContentTypeWebPage) {
        id webpageObject = [[NSClassFromString(@"WXWebpageObject") alloc] init];
        [webpageObject setValue:shareLink.absoluteString forKey:@"webpageUrl"];
        [media setValue:webpageObject forKey:@"mediaObject"];
    } else if (type == SSDKContentTypeImage) {
        id imageObject = [[NSClassFromString(@"WXImageObject") alloc] init];
        //分享的图片在10M以内
        NSData *compressedBigSizeImgData = [self imageDataWithImage:shareImage fixedLength:10 * 1024 * 1024];
        if (!compressedBigSizeImgData) {
            [self showInvaildImgTip];
            return;
        }
        [imageObject setValue:compressedBigSizeImgData forKey:@"imageData"];
        [media setValue:imageObject forKey:@"mediaObject"];
    } else if (type == SSDKContentTypeWXMiniProgram) {
        NSString *miniProgramPath = [parameters valueForKey:@"miniProgramPath"];
        //分享的缩略图32k以内

        NSData *hdImageData = [self imageDataWithImage:shareImage fixedLength:32 * 1024];
        NSString *webpageUrl = [shareLink absoluteString];
        if (!miniProgramPath.length || !hdImageData.length || !webpageUrl.length) {
            [self showInvaildContentTip];
            return;
        }
        id miniProgramObject = [[NSClassFromString(@"WXMiniProgramObject") alloc] init];
        [miniProgramObject setValue:@"gh_899de36ed031" forKey:@"userName"];
        [miniProgramObject setValue:miniProgramPath forKey:@"path"];
        [miniProgramObject setValue:hdImageData forKey:@"hdImageData"];
        [miniProgramObject setValue:webpageUrl forKey:@"webpageUrl"];
        [media setValue:miniProgramObject forKey:@"mediaObject"];
    }
    id req = [[NSClassFromString(@"SendMessageToWXReq") alloc] init];
    [req setValue:@(scene) forKey:@"scene"];
    [req setValue:@(NO) forKey:@"bText"];
    [req setValue:media forKey:@"message"];
    
    [ThirdLoginStorage sharedStorage].shareChangeHander = stateChangedHandler;
    
    [NSClassFromString(@"WXApi") performSelector:@selector(sendReq:completion:) withObject:req withObject:nil];
}
#pragma mark - private 新浪微博
+ (void)sinaWeiboAuthWithChangedHandler:(SSDKAuthorizeStateChangedHandler)stateChangedHandler {
    Class wbAuthorizeRequestClass = NSClassFromString(@"WBAuthorizeRequest");
    if (!wbAuthorizeRequestClass) {
        NSLog(@"微博SDK未集成！！！");
        return;
    }
    [ThirdLoginStorage sharedStorage].authorieChangeHander = stateChangedHandler;
    //        WBAuthorizeRequest *req = [WBAuthorizeRequest request];
    //微博开放平台第三方应用scope，多个scrope用逗号分隔
    //scope为空，默认没有任何高级权限
    //        req.scope = nil;
    //        [WeiboSDK sendRequest:req];
    id req = [wbAuthorizeRequestClass performSelector:@selector(request)];
    [req performSelector:@selector(setRedirectURI:) withObject:[ThirdLoginStorage sharedStorage].weiboRedirectURI];
    [NSClassFromString(@"WeiboSDK") performSelector:@selector(sendRequest:) withObject:req];
}

+ (void)sinaWeiboGetUserInfoWithChangedHandler:(SSDKGetUserStateChangedHandler)stateChangedHandler {
    //新浪微博获取用户信息
    //        + (WBHttpRequest *)requestForUserProfile:(NSString*)aUserID
    //    withAccessToken:(NSString*)accessToken
    //    andOtherProperties:(NSDictionary*)otherProperties
    //    queue:(NSOperationQueue*)queue
    //    withCompletionHandler:(WBRequestHandler)handler;
    NSString *userid = [ThirdLoginStorage sharedStorage].weiboUser.uid;
    NSString *token = [ThirdLoginStorage sharedStorage].weiboUser.credential.token;
    void (^completeBlock)(id request,id result, NSError *error) = ^(id request,id result, NSError *error){
        if ([result isKindOfClass:NSClassFromString(@"WeiboUser")]) {
            SSDKUser *user = [ThirdLoginStorage sharedStorage].weiboUser;
            user.nickname = [result valueForKey:@"screenName"];
            user.icon = [result valueForKey:@"profileImageUrl"];
            user.rawData = [result valueForKey:@"originParaDict"];
            //m--男，f--女,n未知
            if ([[result valueForKey:@"gender"] isEqualToString:@"m"]) {
                user.gender = SSDKGenderMale;
            } else if ([[result valueForKey:@"gender"] isEqualToString:@"f"]) {
                user.gender = SSDKGenderFemale;
            } else {
                user.gender = SSDKGenderUnknown;
            }
            [ThirdLoginStorage sharedStorage].weiboUser = user;
            if (stateChangedHandler) {
                stateChangedHandler(SSDKResponseStateSuccess,user,nil);
            }
        } else {
            if (stateChangedHandler) {
                stateChangedHandler(SSDKResponseStateFail,nil,error);
            }
        }
    };
    SEL selector = @selector(requestForUserProfile:withAccessToken:andOtherProperties:queue:withCompletionHandler:);
    NSMethodSignature *sig = [NSClassFromString(@"WBHttpRequest") methodSignatureForSelector:selector];
    NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setSelector:selector];
    [invo setTarget:NSClassFromString(@"WBHttpRequest")];
    [invo setArgument:&userid atIndex:2];
    [invo setArgument:&token atIndex:3];
    //        [invo setArgument:nil atIndex:4];
    //        [invo setArgument:nil atIndex:5];
    [invo setArgument:&completeBlock atIndex:6];
    [invo invoke];
}

+ (void)sinaWeiboShareWithparameters:(NSMutableDictionary *)parameters
                      onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler {
    if (![NSClassFromString(@"WeiboSDK") performSelector:@selector(isWeiboAppInstalled)]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您未安装新浪微博客户端，请选择其他分享方式"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSString *shareContent = parameters[@"content"];
    //微博分享的内容，必须小于140个字符--新版没有限制了因此去掉了
//    if (shareContent.length >= 140) {
//        shareContent = [NSString stringWithFormat:@"%@...",[shareContent substringToIndex:136]];
//    }
    if (shareContent.length == 0) {
        shareContent = @" ";
    }

    id img = parameters[@"image"];
    UIImage *shareImage = [self loadImage:img];
    if (!shareImage) {
        [self showInvaildImgTip];
        return;
    }
    //调用微博的分享接口
    id wbImageObject = [[NSClassFromString(@"WBImageObject") alloc] init];
    
    NSData *compressedImgData = [self imageDataWithImage:shareImage fixedLength:10 * 1024 * 1024];
    if (!compressedImgData) {
        [self showInvaildImgTip];
        return;
    }
    NSData *imageData = compressedImgData;
    
    [wbImageObject setValue:imageData forKey:@"imageData"];
    
    [ThirdLoginStorage sharedStorage].shareChangeHander = stateChangedHandler;
    
    id messageObject = [NSClassFromString(@"WBMessageObject") performSelector:@selector(message)];
    [messageObject setValue:shareContent forKey:@"text"];
    [messageObject setValue:wbImageObject forKey:@"imageObject"];
    
    id request = [NSClassFromString(@"WBSendMessageToWeiboRequest") performSelector:@selector(requestWithMessage:) withObject:messageObject];
    [NSClassFromString(@"WeiboSDK") performSelector:@selector(sendRequest:) withObject:request];
}

#pragma mark - 工具方法
+ (NSData *)imageDataWithImage:(UIImage *)image fixedLength:(NSInteger)byte {
    CGFloat compressRate = 0.9;
    NSData *imgData = UIImageJPEGRepresentation(image, compressRate);
    while (imgData && imgData.length > byte) {
        compressRate = byte / imgData.length * compressRate;
        NSInteger oldImgDataLength = imgData.length;
        imgData = UIImageJPEGRepresentation(image, compressRate);
        image = [UIImage imageWithData:imgData];
        NSInteger newlyImgDataLength = imgData.length;
        if (oldImgDataLength <= newlyImgDataLength) {
            UIImage *smallImg = [self smallImageFromImg:image];
            if (smallImg) {
                return [self imageDataWithImage:smallImg fixedLength:byte];
            }
            return nil;
        }
    }
    return imgData;
}

+ (UIImage *)smallImageFromImg:(UIImage *)originImg {
    if (originImg.size.height <= 400) {
        return nil;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([originImg CGImage], CGRectMake(0, 0, originImg.size.width, 400));
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

+ (UIImage*)loadImage:(id)img {
    UIImage *shareImage;
    if (img && [img isKindOfClass:[UIImage class]]) {
        shareImage = img;
    } else if (img && [img isKindOfClass:[NSURL class]]) {
        shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL*)img]];
    } else if (img && [img isKindOfClass:[NSString class]]) {
        shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img]]];
    }  else if (img && [img isKindOfClass:[NSData class]]) {
        shareImage = [UIImage imageWithData:img];
    } else {
        shareImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon_120@2x" ofType:@"png"]];
    }
    return shareImage;
}

+ (void)showInvaildImgTip {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"无法获取分享图片"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showInvaildContentTip {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"内容错误，分享失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma clang diagnostic pop

@end

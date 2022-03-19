//
//  SSDKTypeDefine.h
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/17.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef SSDKTypeDefine_h
#define SSDKTypeDefine_h
@class SSDKUser;

typedef NS_ENUM(NSUInteger, SSDKResponseState){
    
    /**
     *  开始
     */
    SSDKResponseStateBegin     = 0,
    
    /**
     *  成功
     */
    SSDKResponseStateSuccess    = 1,
    
    /**
     *  失败
     */
    SSDKResponseStateFail       = 2,
    
    /**
     *  取消
     */
    SSDKResponseStateCancel     = 3
};


typedef NS_ENUM(NSUInteger, SSDKPlatformType){
    /**
     *  未知
     */
    SSDKPlatformTypeUnknown             = 0,
    /**
     *  新浪微博
     */
    SSDKPlatformTypeSinaWeibo           = 1,
    /**
     *  微信平台,
     */
    SSDKPlatformTypeSS              = 2,
    /**
     *  QQ平台
     */
    SSDKPlatformTypeQQ                  = 3,
};

typedef NS_ENUM(NSUInteger, SSDKShareType){
    /**
     *  新浪微博
     */
    SSDKShareTypeSinaWeibo           = 1,
    /**
     *  微信朋友圈,
     */
    SSDKShareTypeSSTimeLine,
    /**
     *  微信好友,
     */
    SSDKShareTypeSSFriend,
    /**
     *  qq好友,
     */
    SSDKShareTypeQQFriend,
    /**
     *  qq空间,
     */
    SSDKShareTypeQZone,
};


typedef NS_ENUM(NSUInteger, SSDKGender){
    /**
     *  男
     */
    SSDKGenderMale      = 0,
    /**
     *  女
     */
    SSDKGenderFemale    = 1,
    /**
     *  未知
     */
    SSDKGenderUnknown   = 2,
};



/**
 *  授权状态变化回调处理器
 *
 *  @param state      状态
 *  @param user       授权用户信息，当且仅当state为SSDKResponseStateSuccess时返回
 *  @param error      错误信息，当且仅当state为SSDKResponseStateFail时返回
 */
typedef void(^SSDKAuthorizeStateChangedHandler) (SSDKResponseState state, SSDKUser *user, NSError *error);

/**
 *  获取用户状态变更回调处理器
 *
 *  @param state 状态
 *  @param user  用户信息，当且仅当state为SSDKResponseStateSuccess时返回
 *  @param error 错误信息，当且仅当state为SSDKResponseStateFail时返回
 */
typedef void(^SSDKGetUserStateChangedHandler) (SSDKResponseState state, SSDKUser *user, NSError *error);

/**
 *  分享内容状态变更回调处理器
 *
 *  @param state            状态
 *  @param userData         附加数据, 返回状态以外的一些数据描述，如：邮件分享取消时，标识是否保存草稿等
 *  @param error            错误信息,当且仅当state为SSDKResponseStateFail时返回
 */
typedef void(^SSDKShareStateChangedHandler) (SSDKResponseState state, NSDictionary *userData,  NSError *error);


/**
 *  内容类型
 */
typedef NS_ENUM(NSUInteger, SSDKContentType){
    /**
     *  图片
     */
    SSDKContentTypeImage        = 2,
    
    /**
     *  网页
     */
    SSDKContentTypeWebPage      = 3,
    
    /**
     *  微信小程序
     */
    SSDKContentTypeWXMiniProgram= 4,
    
};




#endif /* SSDKTypeDefine_h */


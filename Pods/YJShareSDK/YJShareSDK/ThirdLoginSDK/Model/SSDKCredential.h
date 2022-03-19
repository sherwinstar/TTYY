//
//  SSDKCredential.h
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/17.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  授权凭证
 */
@interface SSDKCredential : NSObject

/**
 *  用户标识
 */
@property (nonatomic, copy) NSString *uid;

/**
 *  用户令牌
 */
@property (nonatomic, copy) NSString *token;

/**
 *  用户令牌密钥
 */
@property (nonatomic, copy) NSString *secret;

/**
 *  过期时间
 */
@property (nonatomic, strong) NSDate *expired;

/**
 *  原始数据
 */
@property (nonatomic, strong) NSDictionary *rawData;

/**
 *  标识授权是否可用，YES 可用， NO 已过期
 */
@property (nonatomic, readonly) BOOL available;

/** 用户授权登录后对该用户的唯一标识 */
@property(nonatomic, copy) NSString* openId;

/** Access Token的失效期 */
@property(nonatomic, copy) NSDate* expirationDate;

@end

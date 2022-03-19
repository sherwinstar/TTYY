//
//  NetworkHelper.h
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/23.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkHelper : NSObject

+ (void)requestWithUrl:(NSString *)url completeBlock:(void(^)(NSDictionary *json, NSError *error))block;

@end

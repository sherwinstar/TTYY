//
//  NetworkHelper.m
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/23.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import "NetworkHelper.h"

@implementation NetworkHelper

+ (void)requestWithUrl:(NSString *)url completeBlock:(void(^)(NSDictionary *json, NSError *error))block {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.timeoutInterval = 20;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSError *jsonError = nil;
        if (connectionError || !data.length) {
            if (block) {
                block(nil, connectionError);
            }
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (block) {
            block(json, connectionError);
        }
    }];
}

@end

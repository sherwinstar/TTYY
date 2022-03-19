//
//  NSMutableDictionary+ShareParams.h
//  ThirdLoginSDKCreater
//
//  Created by wangbc on 16/8/22.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDKTypeDefine.h"

@interface NSMutableDictionary (ShareParams)

/**
 *  设置分享参数
 *
 *  @param text     文本
 *  @param images   图片对象,可以是UIImage、NSString（图片路径）、NSURL（图片路径）(暂时只支持UIImage)
 *  @param url      网页路径/应用路径
 *  @param title    标题
 *  @param type     分享类型
 *  @param miniProgramPath   小程序地址
 */
- (void)SSDKSetupShareParamsByText:(NSString *)text
                            image:(id)image
                               url:(NSURL *)url
                             title:(NSString *)title
                              type:(SSDKContentType)type
                   miniProgramPath:(NSString *)miniProgramPath;

@end

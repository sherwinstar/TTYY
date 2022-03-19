//
//  SensorsAnalyticsSDK_priv.h
//  SensorsAnalyticsSDK
//
//  Created by 向作为 on 2018/8/9.
//  Copyright © 2015-2020 Sensors Data Co., Ltd. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#ifndef SensorsAnalyticsSDK_Private_h
#define SensorsAnalyticsSDK_Private_h
#import "SensorsAnalyticsSDK.h"
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "SANetwork.h"
#import "SAHTTPSession.h"
#import "SATrackEventObject.h"
#import "SAAppLifecycle.h"
#import "SASuperProperty.h"

@interface SensorsAnalyticsSDK(Private)

/**
 * @abstract
 * 返回之前所初始化好的单例
 *
 * @discussion
 * 调用这个方法之前，必须先调用 startWithConfigOptions: 。
 * 这个方法与 sharedInstance 类似，但是当远程配置关闭 SDK 时，sharedInstance 方法会返回 nil，这个方法仍然能获取到 SDK 的单例
 *
 * @return 返回的单例
 */
+ (SensorsAnalyticsSDK *)sdkInstance;

#pragma mark - method

/// 事件采集: 切换到 serialQueue 中执行
/// @param object 事件对象
/// @param properties 事件属性
- (void)asyncTrackEventObject:(SABaseEventObject *)object properties:(NSDictionary *)properties;

/// 触发事件
/// @param object 事件对象
/// @param properties 事件属性
- (void)trackEventObject:(SABaseEventObject *)object properties:(NSDictionary *)properties;

/// 开启可视化模块
- (void)enableVisualize;

#pragma mark - property
@property (nonatomic, strong, readonly) SAConfigOptions *configOptions;
@property (nonatomic, readonly, class) SAConfigOptions *configOptions;
@property (nonatomic, strong, readonly) SANetwork *network;
@property (nonatomic, strong, readonly) SASuperProperty *superProperty;
@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;

@end

/**
 SAConfigOptions 实现
 私有 property
 */
@interface SAConfigOptions()

/// 数据接收地址 serverURL
@property(atomic, copy) NSString *serverURL;

/// App 启动的 launchOptions
@property(nonatomic, strong) id launchOptions;

@end

#endif /* SensorsAnalyticsSDK_priv_h */

//
// SAModuleManager+Visualized.h
// SensorsAnalyticsSDK
//
// Created by ๅผ ๆ่ถ๐ on 2021/6/25.
// Copyright ยฉ 2021 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "SAModuleManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAVisualizedModuleProtocol <NSObject>

/// ๅ็ด ็ธๅณๅฑๆง
/// @param view ้่ฆ้้็ view
- (nullable NSDictionary *)propertiesWithView:(UIView *)view;

#pragma mark visualProperties

/// ้้ๅ็ด ่ชๅฎไนๅฑๆง
/// @param view ่งฆๅไบไปถ็ๅ็ด 
/// @param completionHandler ้้ๅฎๆๅ่ฐ
- (void)visualPropertiesWithView:(UIView *)view completionHandler:(void (^)(NSDictionary *_Nullable visualProperties))completionHandler;

@end

@interface SAModuleManager (Visualized) <SAVisualizedModuleProtocol>

@end

NS_ASSUME_NONNULL_END

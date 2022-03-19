//
// SAEventLibObject.h
// SensorsAnalyticsSDK
//
// Created by yuqiang on 2021/4/6.
// Copyright © 2021 Sensors Data Co., Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SAEventLibObject : NSObject

@property (nonatomic, copy) NSString *lib;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, strong) id appVersion;
@property (nonatomic, copy, nullable) NSString *detail;

- (NSMutableDictionary *)jsonObject;

@end

NS_ASSUME_NONNULL_END

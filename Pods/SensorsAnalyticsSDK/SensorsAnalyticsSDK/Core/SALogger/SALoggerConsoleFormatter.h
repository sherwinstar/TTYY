//
//  SALoggerConsoleColorFormatter.h
//  Logger
//
//  Created by 陈玉国 on 2019/12/26.
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

#import <Foundation/Foundation.h>
#import "SAAbstractLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface SALoggerConsoleFormatter : NSObject <SALogMessageFormatter>

@property (nonatomic, copy) NSString *prefix;

@end

NS_ASSUME_NONNULL_END

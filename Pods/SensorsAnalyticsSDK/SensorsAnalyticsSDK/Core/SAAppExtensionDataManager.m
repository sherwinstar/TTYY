//
//  SAAppExtensionDataManager.m
//  SensorsAnalyticsSDK
//
//  Created by 向作为 on 2018/1/18.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif


#import "SAAppExtensionDataManager.h"

void *SAAppExtensionQueueTag = &SAAppExtensionQueueTag;

@interface SAAppExtensionDataManager() {
}
@property (nonatomic, strong) dispatch_queue_t appExtensionQueue;
@end

@implementation SAAppExtensionDataManager

+ (instancetype)sharedInstance {
    static SAAppExtensionDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SAAppExtensionDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.appExtensionQueue = dispatch_queue_create("com.sensorsdata.analytics.appExtensionQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(self.appExtensionQueue, SAAppExtensionQueueTag, &SAAppExtensionQueueTag, NULL);
    }
    return self;
}

- (void)setGroupIdentifierArray:(NSArray *)groupIdentifierArray {
    dispatch_block_t block = ^() {
        self->_groupIdentifierArray = groupIdentifierArray;
    };
    if (dispatch_get_specific(SAAppExtensionQueueTag)) {
        block();
    } else {
        dispatch_async(self.appExtensionQueue, block);
    }
}

- (NSArray *)groupIdentifierArray {
    @try {
        __block NSArray *groupArray = nil;
        dispatch_block_t block = ^() {
            groupArray = self->_groupIdentifierArray;
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return groupArray;
    } @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark -- plistfile
- (NSString *)filePathForApplicationGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return nil;
        }
        __block NSString *filePath = nil;
        dispatch_block_t block = ^() {
            NSURL *pathUrl = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:@"sensors_event_data.plist"];
            filePath = pathUrl.path;
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return filePath;
    } @catch (NSException *exception) {
        return nil;
    }
}

- (NSUInteger)fileDataCountForGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return 0;
        }
        
        __block NSUInteger count = 0;
        dispatch_block_t block = ^() {
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            NSArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
            count = array.count;
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return count;
    } @catch (NSException *exception) {
        return 0;
    }
}

- (NSArray *)fileDataArrayWithPath:(NSString *)path limit:(NSUInteger)limit {
    @try {
        if (![path isKindOfClass:NSString.class] || !path.length) {
            return @[];
        }
        if (limit==0) {
            return @[];
        }
        __block NSArray *dataArray = @[];
        dispatch_block_t block = ^() {
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
            if (array.count >= limit) {
                array = [array subarrayWithRange:NSMakeRange(0, limit)];
            }
            dataArray = array;
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return dataArray;
    } @catch (NSException *exception) {
        return @[];
    }
}

- (BOOL)writeEvent:(NSString *)eventName properties:(NSDictionary *)properties groupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![eventName isKindOfClass:NSString.class] || !eventName.length) {
            return NO;
        }
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return NO;
        }
        if (properties && ![properties isKindOfClass:NSDictionary.class]) {
            return NO;
        }
        
        __block BOOL result = NO;
        dispatch_block_t block = ^{
            NSDictionary *event = @{@"event": eventName, @"properties": properties?properties:@{}};
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            }
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
            if (array.count) {
                [array addObject:event];
            } else {
                array = [NSMutableArray arrayWithObject:event];
            }
            NSError *err = NULL;
            NSData *data= [NSPropertyListSerialization dataWithPropertyList:array
                                                                     format:NSPropertyListBinaryFormat_v1_0
                                                                    options:0
                                                                      error:&err];
            if (path.length && data.length) {
                result = [data  writeToFile:path options:NSDataWritingAtomic error:nil];
            }
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return result;
    } @catch (NSException *exception) {
        return NO;
    }
}

- (NSArray *)readAllEventsWithGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return @[];
        }
        __block NSArray *dataArray = @[];
        dispatch_block_t block = ^() {
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
            dataArray = array;
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return dataArray;
    } @catch (NSException *exception) {
        return @[];
    }
}

- (BOOL)deleteEventsWithGroupIdentifier:(NSString *)groupIdentifier {
    @try {
        if (![groupIdentifier isKindOfClass:NSString.class] || !groupIdentifier.length) {
            return NO;
        }
        __block BOOL result = NO;
        dispatch_block_t block = ^{
            NSString *path = [self filePathForApplicationGroupIdentifier:groupIdentifier];
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
            [array removeAllObjects];
            NSData *data= [NSPropertyListSerialization dataWithPropertyList:array
                                                                     format:NSPropertyListBinaryFormat_v1_0
                                                                    options:0
                                                                      error:nil];
            if (path.length && data.length) {
                result = [data  writeToFile:path options:NSDataWritingAtomic error:nil];
            }
        };
        if (dispatch_get_specific(SAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(self.appExtensionQueue, block);
        }
        return result ;
    } @catch (NSException *exception) {
        return NO;
    }
}

@end

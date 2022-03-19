//
//  YJUMengWrapper.m
//  BaseModule
//
//  Created by Admin on 2020/8/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "YJUMengWrapper.h"
#import <UMCommon/MobClick.h>

@implementation YJUMengWrapper

+ (void)uploadCountEventWithId:(NSString *)eventId label:(nullable NSString *)eventLabel
{
    if (eventId.length) {
        if (eventLabel.length) {
            [MobClick event:eventId label:eventLabel];
        } else {
            [MobClick event:eventId];
        }
    }
}

+ (void)uploadCalculateEventWithId:(NSString *)eventId attributes:(nullable NSDictionary *)eventAttributes {
    if (eventId.length) {
        if (eventAttributes && ![eventAttributes isKindOfClass:[NSNull class]]) {
            [MobClick event:eventId attributes:eventAttributes];
        }
    }
}

@end

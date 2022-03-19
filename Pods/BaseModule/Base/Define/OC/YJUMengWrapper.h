//
//  YJUMengWrapper.h
//  BaseModule
//
//  Created by Admin on 2020/8/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJUMengWrapper : NSObject

+ (void)uploadCountEventWithId:(NSString *)eventId label:(nullable NSString *)eventLabel;

+ (void)uploadCalculateEventWithId:(NSString *)eventId attributes:(nullable NSDictionary *)eventAttributes;

@end

NS_ASSUME_NONNULL_END

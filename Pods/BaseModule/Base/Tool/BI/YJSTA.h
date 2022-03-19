//
//  YJSTA.h
//  BaseApp
//
//  Created by Admin on 2020/7/16.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJSTA : NSObject

+ (void)setUserProfile:(id)profile forKey:(NSString *)key;

+ (void)trackWithEventName:(NSString *)eventName properties:(NSDictionary *)properties;

+ (void)trackViewScreen:(UIViewController *)vc withProperties:(NSDictionary *)properties;

+ (void)trackViewAppClick:(UIView *)view withProperties:(NSDictionary *)properties;

@end

NS_ASSUME_NONNULL_END

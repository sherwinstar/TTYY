//
//  UIResponder+YJEventHandle.h
//  YouShaQi
//
//  Created by 郁玉涛 on 2019/12/27.
//  Copyright © 2019 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (YJEventHandle)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

- (NSInvocation *)createInvocationWithSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END

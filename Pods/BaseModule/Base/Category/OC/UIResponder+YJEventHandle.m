//
//  UIResponder+YJEventHandle.m
//  YouShaQi
//
//  Created by 郁玉涛 on 2019/12/27.
//  Copyright © 2019 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "UIResponder+YJEventHandle.h"

@implementation UIResponder (YJEventHandle)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
//    NSLog(@"class-%@",NSStringFromClass(self.class));
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
    
}

- (NSInvocation *)createInvocationWithSelector:(SEL)selector {

    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    return invocation;
    
}

@end

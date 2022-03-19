//
//  DuoduoJinbaoSDK.h
//  DuoduoJinbao
//
//  Created by fuxuan on 2020/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DDJBCallback)(NSError *_Nullable error);

@interface DuoduoJinbaoSDK : NSObject

+ (void)setupWithCallback:(DDJBCallback)callback;

+ (void)openPDDWithURL:(NSString *)URL callback:(DDJBCallback)callback;

+ (void)openPDDWithURL:(NSString *)URL backURL:(nullable NSString *)backURL callback:(DDJBCallback)callback;

@end

NS_ASSUME_NONNULL_END

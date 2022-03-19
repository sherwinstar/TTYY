//
//  FBEncryptorAESUtils.h
//  YouShaQi
//
//  Created by 蔡三泽 on 15/7/21.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBEncryptorAESUtils : NSObject

+ (NSString *)getDecryptedStrWithKey:(NSString *)key cipherText:(NSString *)cipherText;
+ (NSString *)getDecryptedStrWithKey1:(NSString *)key1 key2:(NSString *)key2 cipherText:(NSString *)cipherText;
+ (NSString *)getIpDecryptedStrWithKey1:(NSString *)key1 key2:(NSString *)key2 cipherText:(NSString *)cipherText;
+ (NSString *)getDecryptedContent:(NSString *)cryptedContent;
+ (NSString *)setEncryptionStringWith:(NSDictionary *)params;

@end

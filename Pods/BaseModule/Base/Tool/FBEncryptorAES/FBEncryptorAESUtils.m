//
//  FBEncryptorAESUtils.m
//  YouShaQi
//
//  Created by 蔡三泽 on 15/7/21.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "FBEncryptorAESUtils.h"
#import "FBEncryptorAES.h"
#import "CustomStringUtils.h"
#import "YJIdfaHelper.h"

@implementation FBEncryptorAESUtils

+ (NSString *)getDecryptedStrWithKey:(NSString *)key cipherText:(NSString *)cipherText
{
    if ([CustomStringUtils isBlankString:cipherText] || [CustomStringUtils isBlankString:key]) {
        return @"";
    }
    NSInteger ivLength = 16;
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:0];
    NSData *decodedCipherTextData = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    if (decodedCipherTextData.length<ivLength) {
        return @"";
    }
    NSData *clipedIvData = [decodedCipherTextData subdataWithRange:NSMakeRange(0, ivLength)];
    NSData *clipedCipherTextData = [decodedCipherTextData subdataWithRange:NSMakeRange(ivLength, [decodedCipherTextData length] - ivLength)];;
    NSData *decryptedData = [FBEncryptorAES decryptData:clipedCipherTextData key:keyData iv:clipedIvData];
    
    NSString *decryptedStr = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return decryptedStr;
}

+ (NSString *)getDecryptedStrWithKey1:(NSString *)key1 key2:(NSString *)key2 cipherText:(NSString *)cipherText
{
    if ([CustomStringUtils isBlankString:cipherText] || [CustomStringUtils isBlankString:key1] || [CustomStringUtils isBlankString:key2]) {
        return @"";
    }
    
    NSInteger ivLength = 16;
    NSData *key1Data = [key1 dataUsingEncoding:NSUTF8StringEncoding];
    NSData *key2Data = [key2 dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decodedCipherTextData = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    NSData *firstClipedIvData = [decodedCipherTextData subdataWithRange:NSMakeRange(0, ivLength)];
    NSData *firstClipedCipherTextData = [decodedCipherTextData subdataWithRange:NSMakeRange(ivLength, [decodedCipherTextData length] - ivLength)];
    NSData *firstDecryptedData = [FBEncryptorAES decryptData:firstClipedCipherTextData key:key1Data iv:firstClipedIvData];
    NSString *firstDecryptedStr = [[NSString alloc] initWithData:firstDecryptedData encoding:NSUTF8StringEncoding];
    
    if ([CustomStringUtils isBlankString:firstDecryptedStr]) {
        return @"";
    }

    NSData *secondCipherTextData = [[NSData alloc] initWithBase64EncodedString:firstDecryptedStr options:0];
    NSData *secondClipedIvData = [secondCipherTextData subdataWithRange:NSMakeRange(0, ivLength)];
    NSData *secondClipedCipherTextData = [secondCipherTextData subdataWithRange:NSMakeRange(ivLength, [secondCipherTextData length] - ivLength)];
    NSData *secondDecryptedData = [FBEncryptorAES decryptData:secondClipedCipherTextData key:key2Data iv:secondClipedIvData];
    
    NSString *decryptedStr = [[NSString alloc] initWithData:secondDecryptedData encoding:NSUTF8StringEncoding];
    
    return decryptedStr;
}

+ (NSString *)getIpDecryptedStrWithKey1:(NSString *)key1 key2:(NSString *)key2 cipherText:(NSString *)cipherText
{
    if ([CustomStringUtils isBlankString:cipherText] || [CustomStringUtils isBlankString:key1] || [CustomStringUtils isBlankString:key2]) {
        return @"";
    }
    
    NSInteger ivLength = 16;
    NSData *key1Data = [[NSData alloc] initWithBase64EncodedString:key1 options:0];
    NSData *key2Data = [[NSData alloc] initWithBase64EncodedString:key2 options:0];
    NSData *decodedCipherTextData = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    NSData *firstClipedIvData = [decodedCipherTextData subdataWithRange:NSMakeRange(0, ivLength)];
    NSData *firstClipedCipherTextData = [decodedCipherTextData subdataWithRange:NSMakeRange(ivLength, [decodedCipherTextData length] - ivLength)];
    NSData *firstDecryptedData = [FBEncryptorAES decryptData:firstClipedCipherTextData key:key1Data iv:firstClipedIvData];
    NSString *firstDecryptedStr = [[NSString alloc] initWithData:firstDecryptedData encoding:NSUTF8StringEncoding];
    if ([CustomStringUtils isBlankString:firstDecryptedStr]) {
        return @"";
    }
    
    NSData *secondCipherTextData = [[NSData alloc] initWithBase64EncodedString:firstDecryptedStr options:0];
    NSData *secondClipedIvData = [secondCipherTextData subdataWithRange:NSMakeRange(0, ivLength)];
    NSData *secondClipedCipherTextData = [secondCipherTextData subdataWithRange:NSMakeRange(ivLength, [secondCipherTextData length] - ivLength)];
    NSData *secondDecryptedData = [FBEncryptorAES decryptData:secondClipedCipherTextData key:key2Data iv:secondClipedIvData];
    
    NSString *decryptedStr = [[NSString alloc] initWithData:secondDecryptedData encoding:NSUTF8StringEncoding];
    
    return decryptedStr;
}

+ (NSString *)getDecryptedContent:(NSString *)cryptedContent {
    if ([CustomStringUtils isBlankString:cryptedContent]) {
        return @"";
    }
    NSData *keyData = [@"+BNC7v+HXyt7bJlp" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [@"581ec9051f4cb2e6" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decodedCipherTextData = [[NSData alloc] initWithBase64EncodedString:cryptedContent options:0];
    NSData *decryptedData = [FBEncryptorAES decryptData:decodedCipherTextData key:keyData iv:ivData];
    NSString *decryptedStr = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return decryptedStr;
}

+ (NSString *)setEncryptionStringWith:(NSDictionary *)params {
    NSData *keyData = [@"+BNC7v+HXyt7bJlp" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [@"581ec9051f4cb2e6" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *lbsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSData *encryptedData = [FBEncryptorAES encryptData:lbsData key:keyData iv:ivData];
    NSData *aData = [[YJIdfaHelper uniquelIdfa] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *resultData = [self xorEncodeData:encryptedData withKey:aData];
    NSString *resultStr = [resultData base64EncodedStringWithOptions:0];
    return resultStr;
}

// 加密后的字符串第一位与deviceId第一位异或
+ (NSData *)xorEncodeData:(NSData *)sourceData withKey:(NSData *)keyData {
    Byte *sourceBytes = (Byte *)[sourceData bytes]; //取需要加密的数据的Byte数组
    Byte *keyBytes = (Byte *)[keyData bytes]; //取关键字的Byte数组, keyBytes一直指向头部
    sourceBytes[0] = sourceBytes[0] ^ keyBytes[0]; //然后按位进行异或运算
    NSData *newData = [[NSData alloc] initWithBytes:sourceBytes length:[sourceData length]];
    return newData;
}

@end

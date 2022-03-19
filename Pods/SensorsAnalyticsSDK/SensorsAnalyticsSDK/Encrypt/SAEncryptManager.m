//
// SAEncryptManager.m
// SensorsAnalyticsSDK
//
// Created by 张敏超🍎 on 2020/11/25.
// Copyright © 2020 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SAEncryptManager.h"
#import "SAValidator.h"
#import "SAURLUtils.h"
#import "SAAlertController.h"
#import "SAFileStore.h"
#import "SAJSONUtil.h"
#import "SAGzipUtility.h"
#import "SALog.h"
#import "SARSAPluginEncryptor.h"
#import "SAECCPluginEncryptor.h"
#import "SAConfigOptions+Encrypt.h"
#import "SASecretKeyFactory.h"

static NSString * const kSAEncryptSecretKey = @"SAEncryptSecretKey";

@interface SAEncryptManager ()

/// 当前使用的加密插件
@property (nonatomic, strong) id<SAEncryptProtocol> encryptor;

/// 当前支持的加密插件列表
@property (nonatomic, copy) NSArray<id<SAEncryptProtocol>> *encryptors;

@property (nonatomic, copy) NSString *encryptedSymmetricKey;

/// 非对称密钥加密器的公钥（RSA/ECC 的公钥）
@property (nonatomic, strong) SASecretKey *secretKey;

@end

@implementation SAEncryptManager

#pragma mark - SAModuleProtocol

- (void)setEnable:(BOOL)enable {
    _enable = enable;

    if (enable) {
        [self updateEncryptor];
    }
}

- (void)setConfigOptions:(SAConfigOptions *)configOptions {
    _configOptions = configOptions;

    NSMutableArray *encryptors = [NSMutableArray array];
    [encryptors addObject:[[SAECCPluginEncryptor alloc] init]];
    [encryptors addObject:[[SARSAPluginEncryptor alloc] init]];
    [encryptors addObjectsFromArray:configOptions.encryptors];
    self.encryptors = encryptors;
}

#pragma mark - SAOpenURLProtocol

- (BOOL)canHandleURL:(nonnull NSURL *)url {
    return [url.host isEqualToString:@"encrypt"];
}

- (BOOL)handleURL:(nonnull NSURL *)url {
    NSString *message = @"当前 App 未开启加密，请开启加密后再试";

    if (self.enable) {
        NSDictionary *paramDic = [SAURLUtils queryItemsWithURL:url];
        NSString *urlVersion = paramDic[@"v"];
        NSString *urlKey = paramDic[@"key"];

        if ([SAValidator isValidString:urlVersion] && [SAValidator isValidString:urlKey]) {
            SASecretKey *secretKey = [self loadCurrentSecretKey];
            NSString *loadVersion = [@(secretKey.version) stringValue];
            // url 中的 key 为 encode 之后的
            NSString *loadKey = [secretKey.key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];

            if ([loadVersion isEqualToString:urlVersion] && [loadKey isEqualToString:urlKey]) {
                message = @"密钥验证通过，所选密钥与 App 端密钥相同";
            } else if (![SAValidator isValidString:loadKey]) {
                message = @"密钥验证不通过，App 端密钥为空";
            } else {
                message = [NSString stringWithFormat:@"密钥验证不通过，所选密钥与 App 端密钥不相同。所选密钥版本:%@，App 端密钥版本:%@", urlVersion, loadVersion];
            }
        } else {
            message = @"密钥验证不通过，所选密钥无效";
        }
    }

    SAAlertController *alertController = [[SAAlertController alloc] initWithTitle:nil message:message preferredStyle:SAAlertControllerStyleAlert];
    [alertController addActionWithTitle:@"确认" style:SAAlertActionStyleDefault handler:nil];
    [alertController show];
    return YES;
}

#pragma mark - SAEncryptModuleProtocol
- (BOOL)hasSecretKey {
    // 当可以获取到秘钥时，不需要强制性触发远程配置请求秘钥
    SASecretKey *sccretKey = [self loadCurrentSecretKey];
    return (sccretKey.key.length > 0);
}

- (NSDictionary *)encryptJSONObject:(id)obj {
    @try {
        if (!obj) {
            SALogDebug(@"Enable encryption but the input obj is invalid!");
            return nil;
        }

        if (!self.encryptor) {
            SALogDebug(@"Enable encryption but the secret key is invalid!");
            return nil;
        }

        if (![self encryptSymmetricKey]) {
            SALogDebug(@"Enable encryption but encrypt symmetric key is failed!");
            return nil;
        }

        // 使用 gzip 进行压缩
        NSData *jsonData = [SAJSONUtil dataWithJSONObject:obj];
        NSData *zippedData = [SAGzipUtility gzipData:jsonData];

        // 加密数据
        NSString *encryptedString =  [self.encryptor encryptEvent:zippedData];
        if (![SAValidator isValidString:encryptedString]) {
            return nil;
        }

        // 封装加密的数据结构
        NSMutableDictionary *secretObj = [NSMutableDictionary dictionary];
        secretObj[@"pkv"] = @(self.secretKey.version);
        secretObj[@"ekey"] = self.encryptedSymmetricKey;
        secretObj[@"payload"] = encryptedString;
        return [NSDictionary dictionaryWithDictionary:secretObj];
    } @catch (NSException *exception) {
        SALogError(@"%@ error: %@", self, exception);
        return nil;
    }
}

- (BOOL)encryptSymmetricKey {
    if (self.encryptedSymmetricKey) {
        return YES;
    }
    NSString *publicKey = self.secretKey.key;
    self.encryptedSymmetricKey = [self.encryptor encryptSymmetricKeyWithPublicKey:publicKey];
    return self.encryptedSymmetricKey != nil;
}

#pragma mark - handle remote config for secret key
- (void)handleEncryptWithConfig:(NSDictionary *)encryptConfig {
    if (!encryptConfig) {
        return;
    }
    SASecretKey *secretKey = [SASecretKeyFactory generateSecretKeyWithRemoteConfig:encryptConfig];
    if (![self encryptorWithSecretKey:secretKey]) {
        //当前秘钥没有对应的加密器
        return;
    }
    // 存储请求的公钥
    [self saveRequestSecretKey:secretKey];
    // 更新加密构造器
    [self updateEncryptor];
}

- (void)updateEncryptor {
    @try {
        SASecretKey *secretKey = [self loadCurrentSecretKey];
        if (![SAValidator isValidString:secretKey.key]) {
            return;
        }

        if (secretKey.version <= 0) {
            return;
        }

        // 返回的密钥与已有的密钥一样则不需要更新
        if ([self isSameSecretKey:self.secretKey newSecretKey:secretKey]) {
            return;
        }

        id<SAEncryptProtocol> encryptor = [self filterEncrptor:secretKey];
        if (!encryptor) {
            return;
        }

        NSString *encryptedSymmetricKey = [encryptor encryptSymmetricKeyWithPublicKey:secretKey.key];
        if ([SAValidator isValidString:encryptedSymmetricKey]) {
            // 更新密钥
            self.secretKey = secretKey;
            // 更新加密插件
            self.encryptor = encryptor;
            // 重新生成加密插件的对称密钥
            self.encryptedSymmetricKey = encryptedSymmetricKey;
        }
    } @catch (NSException *exception) {
        SALogError(@"%@ error: %@", self, exception);
    }
}

- (BOOL)isSameSecretKey:(SASecretKey *)currentSecretKey newSecretKey:(SASecretKey *)newSecretKey {
    if (currentSecretKey.version != newSecretKey.version) {
        return NO;
    }
    if (![currentSecretKey.key isEqualToString:newSecretKey.key]) {
        return NO;
    }
    if (![currentSecretKey.symmetricEncryptType isEqualToString:newSecretKey.symmetricEncryptType]) {
        return NO;
    }
    if (![currentSecretKey.asymmetricEncryptType isEqualToString:newSecretKey.asymmetricEncryptType]) {
        return NO;
    }
    return YES;
}

- (id<SAEncryptProtocol>)filterEncrptor:(SASecretKey *)secretKey {
    id<SAEncryptProtocol> encryptor = [self encryptorWithSecretKey:secretKey];
    // 特殊处理，当秘钥类型为 ECC 且未集成 ECC 加密库时，进行断言提示
    if ((!NSClassFromString(kSAEncryptECCClassName) && [encryptor isKindOfClass:SAECCPluginEncryptor.class])) {
        NSAssert(NO, @"\n您使用了 ECC 密钥，但是并没有集成 ECC 加密库。\n • 如果使用源码集成 ECC 加密库，请检查是否包含名为 SAECCEncrypt 的文件? \n • 如果使用 CocoaPods 集成 SDK，请修改 Podfile 文件并增加 ECC 模块，例如：pod 'SensorsAnalyticsEncrypt'。\n");
        return nil;
    }
    return encryptor;
}

- (id<SAEncryptProtocol>)encryptorWithSecretKey:(SASecretKey *)secretKey {
    if (!secretKey) {
        return nil;
    }
    __block id<SAEncryptProtocol> encryptor;
    [self.encryptors enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<SAEncryptProtocol> obj, NSUInteger idx, BOOL *stop) {
        if ([self checkEncryptType:obj secretKey:secretKey]) {
            encryptor = obj;
            *stop = YES;
        }
    }];
    return encryptor;
}

- (BOOL)checkEncryptType:(id<SAEncryptProtocol>)encryptor secretKey:(SASecretKey *)secretKey {
    if (![[encryptor symmetricEncryptType] isEqualToString:secretKey.symmetricEncryptType]) {
        return NO;
    }
    if (![[encryptor asymmetricEncryptType] isEqualToString:secretKey.asymmetricEncryptType]) {
        return NO;
    }
    return YES;
}

#pragma mark - archive/unarchive secretKey
- (void)saveRequestSecretKey:(SASecretKey *)secretKey {
    if (!secretKey) {
        return;
    }

    void (^saveSecretKey)(SASecretKey *) = self.configOptions.saveSecretKey;
    if (saveSecretKey) {
        // 通过用户的回调保存公钥
        saveSecretKey(secretKey);

        [SAFileStore archiveWithFileName:kSAEncryptSecretKey value:nil];

        SALogDebug(@"Save secret key by saveSecretKey callback, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
    } else {
        // 存储到本地
        NSData *secretKeyData = [NSKeyedArchiver archivedDataWithRootObject:secretKey];
        [SAFileStore archiveWithFileName:kSAEncryptSecretKey value:secretKeyData];

        SALogDebug(@"Save secret key by localSecretKey, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
    }
}

- (SASecretKey *)loadCurrentSecretKey {
    SASecretKey *secretKey = nil;

    SASecretKey *(^loadSecretKey)(void) = self.configOptions.loadSecretKey;
    if (loadSecretKey) {
        // 通过用户的回调获取公钥
        secretKey = loadSecretKey();

        if (secretKey) {
            SALogDebug(@"Load secret key from loadSecretKey callback, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
        } else {
            SALogDebug(@"Load secret key from loadSecretKey callback failed!");
        }
    } else {
        // 通过本地获取公钥
        id secretKeyData = [SAFileStore unarchiveWithFileName:kSAEncryptSecretKey];
        if ([SAValidator isValidData:secretKeyData]) {
            secretKey = [NSKeyedUnarchiver unarchiveObjectWithData:secretKeyData];
        }

        if (secretKey) {
            SALogDebug(@"Load secret key from localSecretKey, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
        } else {
            SALogDebug(@"Load secret key from localSecretKey failed!");
        }
    }

    // 兼容老版本保存的秘钥
    if (!secretKey.symmetricEncryptType) {
        secretKey.symmetricEncryptType = kSAAlgorithmTypeAES;
    }
    if (!secretKey.asymmetricEncryptType) {
        BOOL isECC = [secretKey.key hasPrefix:kSAAlgorithmTypeECC];
        secretKey.asymmetricEncryptType = isECC ? kSAAlgorithmTypeECC : kSAAlgorithmTypeRSA;
    }
    return secretKey;
}

@end

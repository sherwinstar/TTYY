//  UIView+SAElementSelector.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright © 2015-2019 Sensors Data Inc. All rights reserved.
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

#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import "SensorsAnalyticsSDK.h"
#import "UIView+SAElementSelector.h"

// NB If you add any more fingerprint methods, increment this.
#define SA_FINGERPRINT_VERSION 1

@implementation UIView (SAElementSelector)

- (int)jjf_fingerprintVersion {
    return SA_FINGERPRINT_VERSION;
}

// 在 controller 上的成员变量
- (NSString *)sa_controllerVariable {
    if (![self isKindOfClass:[UIControl class]]) {
        return nil;
    }
    NSString *result = nil;
    UIResponder *responder = [self nextResponder];
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    if (responder) {
        uint count;
        Ivar *ivars = class_copyIvarList([responder class], &count);
        for (uint i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            const char *objCType = ivar_getTypeEncoding(ivar);
            if (objCType) {
                if (objCType[0] == '@' && object_getIvar(responder, ivar) == self) {
                    result = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
                    break;
                }
            }
        }
        free(ivars);
    }
    return result;
}

/*
 Creates a short string which is a fingerprint of a UIButton's image property.
 It does this by downsampling the image to 8x8 and then downsampling the resulting
 32bit pixel data to 8 bit. This should allow us to select images that are identical or
 almost identical in appearance without having to compare the whole image.
 
 Returns a base64 encoded string representing an 8x8 bitmap of 8 bit rgba data
 (2 bits per component).
 */
- (NSString *)sa_imageFingerprint {
    UIImage *originalImage = nil;
    if ([self isKindOfClass:[UIButton class]]) {
        originalImage = [((UIButton *)self) imageForState:UIControlStateNormal];
    } else if ([NSStringFromClass([self class]) isEqual:@"UITabBarButton"] && [self.subviews count] > 0 && [self.subviews[0] respondsToSelector:NSSelectorFromString(@"image")]) {
        originalImage = (UIImage *)[self.subviews[0] performSelector:@selector(image)];
    }
    if (!originalImage) {
        return nil;
    }
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    uint32_t data32[64];
    uint8_t data4[32];
    CGContextRef context = CGBitmapContextCreate(data32, 8, 8, 8, 8*4, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextClearRect(context, CGRectMake(0, 0, 8, 8));
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGRectMake(0,0,8,8), [originalImage CGImage]);
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    for(int i = 0; i < 32; i++) {
        int j = 2*i;
        int k = 2*i + 1;
        data4[i] = (((data32[j] & 0x80000000) >> 24) | ((data32[j] & 0x800000) >> 17) | ((data32[j] & 0x8000) >> 10) | ((data32[j] & 0x80) >> 3) |
                    ((data32[k] & 0x80000000) >> 28) | ((data32[k] & 0x800000) >> 21) | ((data32[k] & 0x8000) >> 14) | ((data32[k] & 0x80) >> 7));
    }
    return [[NSData dataWithBytes:data4 length:32] base64EncodedStringWithOptions:0];
}

- (NSString *)sa_text {
    NSString *text = nil;
    SEL titleSelector = NSSelectorFromString(@"title");
    if ([self isKindOfClass:[UILabel class]]) {
        text = ((UILabel *)self).text;
    } else if ([self isKindOfClass:[UIButton class]]) {
        text = [((UIButton *)self) titleForState:UIControlStateNormal];
    } else if ([self respondsToSelector:titleSelector]) {
        IMP titleImp = [self methodForSelector:titleSelector];
        void *(*func)(id, SEL) = (void *(*)(id, SEL))titleImp;
        id title = (__bridge id)func(self, titleSelector);
        if ([title isKindOfClass:[NSString class]]) {
            text = title;
        }
    }
    return text;
}

static NSString* sa_encryptHelper(id input) {
    NSString *SALT = @"dbba253e672cc94bee5da560040b47b1";
    NSMutableString *encryptedStuff = nil;
    if ([input isKindOfClass:[NSString class]]) {
        NSData *data = [[input stringByAppendingString:SALT]  dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t digest[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
        encryptedStuff = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [encryptedStuff appendFormat:@"%02x", digest[i]];
        }
    }
    return encryptedStuff;
}

#pragma mark - Aliases for compatibility
- (NSString *)jjf_varA {
    return sa_encryptHelper(self.sensorsAnalyticsViewID);
}

- (NSString *)jjf_varB {
    return sa_encryptHelper([self sa_controllerVariable]);
}

- (NSString *)jjf_varC {
    return sa_encryptHelper([self sa_imageFingerprint]);
}

// 获取内容
- (NSString *)jjf_varE {
    return sa_encryptHelper([self sa_text]);
}

@end

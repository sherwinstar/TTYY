//
//  YJIdfaHelper.m
//  YouShaQi
//
//  Created by 蔡三泽 on 14-1-15.
//  Copyright (c) 2014年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "YJIdfaHelper.h"
//for mac
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//for idfa
#import <AdSupport/AdSupport.h>
#import "SFHFKeychainUtilsYouShaQi.h"
#import "CustomStringUtils.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation YJIdfaHelper

+ (NSString *)macString {
    
	int 				mib[6];
	size_t 				len;
	char 				*buf;
	unsigned char	 	*ptr;
	struct if_msghdr 	*ifm;
	struct sockaddr_dl 	*sdl;
    
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
    
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error\n");
		return @"";
	}
    
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1\n");
		return @"";
	}
    
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!\n");
		return @"";
	}
    
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return @"";
	}
    
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
    
	return macString ? macString : @"";
}

+ (BOOL)isIdfaAdvertisingTrackingEnabled {
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
    if (@available(iOS 14.5, *)) {
        ATTrackingManagerAuthorizationStatus states = [ATTrackingManager trackingAuthorizationStatus];
        if (states != ATTrackingManagerAuthorizationStatusAuthorized) {
            return NO;
        }
    } else if (@available(iOS 14, *)) {
        return YES;
    } else {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] == NO) {
            return NO;
        }
    }
    return YES;
}

+ (NSString *)idfaString {
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    } else {
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        } else {
            NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            return idfa ? idfa : @"";
        }
    }
}

+ (NSString *)idfvString {
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}


+ (NSString *)uniquelIdfa {
    NSString *idfaString = [YJIdfaHelper idfaString];
    if (![YJIdfaHelper isInvalidIdfa:idfaString]) {
        return idfaString;
    }
    NSString *uniqueIdfa = [SFHFKeychainUtilsYouShaQi getPasswordForUsername:@"uniqueIdfa" andServiceName:@"YouShaQi" error:nil];
    if (uniqueIdfa == nil || [self isInvalidIdfa:uniqueIdfa]) {
        uniqueIdfa = [YJIdfaHelper idfaString];
        if (!uniqueIdfa.length || ![YJIdfaHelper isIdfaAdvertisingTrackingEnabled] || [self isInvalidIdfa:uniqueIdfa]) {
            uniqueIdfa = [YJIdfaHelper customUniquelUserId];
        }
        [SFHFKeychainUtilsYouShaQi storeUsername:@"uniqueIdfa" andPassword:uniqueIdfa forServiceName:@"YouShaQi" updateExisting:YES error:nil];
        return uniqueIdfa;
    } else {
        return uniqueIdfa;
    }
}

+ (BOOL)isInvalidIdfa:(NSString *)idfa {
    if ([CustomStringUtils isBlankString:idfa] ||
        [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)customUniquelUserId {
    char data[40];
    for (int x=0;x<40;data[x++] = (char)('a' + (arc4random_uniform(26))));
    int time = (int)[[NSDate date] timeIntervalSince1970];
    NSString *arcStr = [[NSString alloc] initWithBytes:data length:40 encoding:NSUTF8StringEncoding];
    NSString *idfa = [NSString stringWithFormat:@"yk%@%d",arcStr,time];
    return idfa;
}

+ (void)resetUniquelIdfa {
    [SFHFKeychainUtilsYouShaQi deleteItemForUsername:@"uniqueIdfa" andServiceName:@"YouShaQi" error:nil];
    NSString *uniqueIdfa = [YJIdfaHelper uniquelIdfa];
    [SFHFKeychainUtilsYouShaQi storeUsername:@"uniqueIdfa" andPassword:uniqueIdfa forServiceName:@"YouShaQi" updateExisting:YES error:nil];
}

@end

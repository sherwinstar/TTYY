//
//  TYUrlUtils.m
//  TTYY
//
//  Created by YJPRO on 2021/9/29.
//

#import "TYUrlUtils.h"

@implementation TYUrlUtils


+ (NSString *)encodeToPercentEscapeString:(NSString *)input {
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}

@end

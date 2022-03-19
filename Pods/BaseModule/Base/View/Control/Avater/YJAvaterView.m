//
//  YJAvaterView.m
//  BaseModule
//
//  Created by Admin on 2020/10/19.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "YJAvaterView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+YJ.h"

#if TARGET_ZSSQ
static NSString *kAvaterViewDefaultImgName = @"phone_login_default_avatar";
#else
static NSString *kAvaterViewDefaultImgName = @"mine_defualt_head";
#endif

@interface YJAvaterView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *defaultImgName;
@property (nonatomic, weak) id<YJAvaterViewDelegate> delegate;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation YJAvaterView

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius url:(NSString *)url delegate:(id<YJAvaterViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.radius = radius;
        self.url = url;
        self.delegate = delegate;
    }
    return self;
}

- (void)setup {
    NSURL *url = [self.url queryEncodedURLString];
    [self sd_setImageWithURL:url placeholderImage:[self defaultImgName]];
    
    self.layer.cornerRadius = self.radius;
    if (self.radius > 0) {
        self.layer.masksToBounds = YES;
    }
    
    if (self.delegate != nil) {
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [self addGestureRecognizer:self.tap];
    }
}

- (void)handleTapAction:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(avaterViewDidClick:)]) {
        [self.delegate avaterViewDidClick:self];
    }
}

- (void)updateUrl:(NSString *)urlString {
    self.url = urlString;
    NSURL *url = [NSURL URLWithString:[urlString queryEncodedURLString]];
    [self sd_setImageWithURL:url placeholderImage:[self defaultImgName]];
}

- (UIImage *)defaultImg {
    if (self.defaultImgName != nil) {
        return [UIImage imageNamed:self.defaultImgName];
    } else if (kAvaterViewDefaultImgName != nil) {
        return [UIImage imageNamed:kAvaterViewDefaultImgName];
    }
    return nil;
}

- (void)updateDefaultAvaterImgName:(NSString *)defaultImgName {
    self.defaultImgName = defaultImgName;
    self.image = [self defaultImgName];
}

@end

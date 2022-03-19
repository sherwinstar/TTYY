//
//  YJActionImageView.m
//  YouShaQi
//
//  Created by Lee on 2018/6/15.
//  Copyright © 2018 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "YJActionImageView.h"

@interface YJActionImageView()

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation YJActionImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        _tap = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:_tap];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    [self.tap addTarget:target action:action];
}

- (void)setImage:(UIImage *)image {
    UIImage *newImage = [self image:image cornerRadius:self.cornerRadius];
    [super setImage:newImage];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    
    if (self.image) {
        // 重新调set方法
        [self setImage:self.image];
    }
}

- (UIImage *)image:(UIImage *)img cornerRadius:(CGFloat)radius {
    CGRect rect = (CGRect){0.f, 0.f, img.size};
    UIGraphicsBeginImageContextWithOptions(img.size, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius * 2].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [img drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

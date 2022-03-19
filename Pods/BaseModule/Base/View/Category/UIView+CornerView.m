//
//  UIView+CornerView.m
//  YouShaQi
//
//  Created by 张胜 on 2018/9/16.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "UIView+CornerView.h"

@implementation UIView (CornerView)
- (void)drawCornerWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii maskLayerFillColor:(UIColor *)fillColor
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [self maskLayerWithPath:maskPath fillColor:fillColor];
    [self.layer addSublayer:maskLayer];
}
- (void)drawCornerWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii maskLayerFillColor:(UIColor *)fillColor shadowColor:(UIColor *)shadowColor shadowRadius :(CGFloat)shadowRadius shadowOpacity:(CGFloat)shadowOpacity  shadowOffset:(CGSize)shadowOffset
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [self maskLayerWithPath:maskPath fillColor:fillColor];
    [maskLayer setShadowColor:shadowColor.CGColor];
    [maskLayer setShadowRadius:shadowRadius];
    [maskLayer setShadowOpacity:shadowOpacity];
    maskLayer.shadowOffset = shadowOffset;
    [self.layer addSublayer:maskLayer];
}
#pragma mark -- private
- (CAShapeLayer *)maskLayerWithPath:(UIBezierPath *)path fillColor:(UIColor *)fillColor
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path  = path.CGPath;
    maskLayer.fillColor = fillColor.CGColor;
    return maskLayer;
}
@end

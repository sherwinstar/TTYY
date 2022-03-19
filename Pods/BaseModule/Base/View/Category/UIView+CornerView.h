//
//  UIView+CornerView.h
//  YouShaQi
//
//  Created by 张胜 on 2018/9/16.
//  Copyright © 2018年 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CornerView)
// 圆角
- (void)drawCornerWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii maskLayerFillColor:(UIColor *)fillColor;
// 圆角和阴影
- (void)drawCornerWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii maskLayerFillColor:(UIColor *)fillColor shadowColor:(UIColor *)shadowColor shadowRadius :(CGFloat)shadowRadius shadowOpacity:(CGFloat)shadowOpacity shadowOffset:(CGSize)shadowOffset;
@end

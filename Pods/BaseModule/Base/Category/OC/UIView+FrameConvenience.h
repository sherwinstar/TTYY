//
//  UIView+FrameConvenience.h
//  YouShaQi
//
//  Created by     on 2017/5/19.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameConvenience)

@property (nonatomic, readwrite) CGFloat x;      //left
@property (nonatomic, readwrite) CGFloat y;      //top
@property (nonatomic, readwrite) CGFloat right;
@property (nonatomic, readwrite) CGFloat width;
@property (nonatomic, readwrite) CGFloat height;
@property (nonatomic, readwrite) CGFloat bottom;

@property (nonatomic, readwrite) CGFloat centerX;
@property (nonatomic, readwrite) CGFloat centerY;

@property (nonatomic, readwrite) CGPoint origin;
@property (nonatomic, readwrite) CGSize size;


- (CGFloat)getFrameRight;
- (CGFloat)getFrameBottom;

@end

@interface UIDevice (SafeArea)

+ (UIEdgeInsets)safeAreaInsets;

@end

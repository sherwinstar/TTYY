//
//  UIView+MultipleConstraints.h
//  YouShaQi
//
//  Created by 蔡三泽 on 15/1/7.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MultipleConstraints)
- (void)addConstraintsWithVisualFormats:(NSArray *)visualFormats viewsDic:(NSDictionary *)views option:(NSLayoutFormatOptions)option;
- (void)horizontallyCenterSubview:(UIView *)subview;
- (void)verticallyCenterSubview:(UIView *)subview;
- (void)centerSubView:(UIView *)subview;

- (void)resetSubViewWidthEqualToSuperView:(UIView *)subView;
- (void)resetSubViewSizeEqualToSuperView:(UIView *)subView;

- (void)alignLeftSubview:(UIView *)subView withLeftPadding:(CGFloat)LeftPadding bottomPadding:(CGFloat)bottomPadding;
- (void)alignRightSubview:(UIView *)subView withRightPadding:(CGFloat)rightPadding bottomPadding:(CGFloat)bottomPadding;
- (void)alignRightSubview:(UIView *)subView withRightPadding:(CGFloat)rightPadding topPadding:(CGFloat)topPadding;
- (void)alignCenterSubview:(UIView *)subView withBottomPadding:(CGFloat)bottomPadding;
- (void)alignCenterSubview:(UIView *)subView withTopPadding:(CGFloat)TopPadding;

//- (void)resetViewFrameWithSize:(CGSize)size isLandscapeMode:(BOOL)isLandscapeMode;

@end

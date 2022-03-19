//
//  UIView+MultipleConstraints.m
//  YouShaQi
//
//  Created by 蔡三泽 on 15/1/7.
//  Copyright (c) 2015年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import "UIView+MultipleConstraints.h"

@implementation UIView (MultipleConstraints)

- (void)addConstraintsWithVisualFormats:(NSArray *)visualFormats viewsDic:(NSDictionary *)views option:(NSLayoutFormatOptions)option
{
    for (NSString *visualFormat in visualFormats) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                       options:option
                                                                       metrics:nil
                                                                         views:views];
        [self addConstraints:constraints];
    }
}

- (void)horizontallyCenterSubview:(UIView *)subview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self addConstraint:centerXConstraint];
}

- (void)verticallyCenterSubview:(UIView *)subview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self addConstraint:centerYConstraint];
}

- (void)centerSubView:(UIView *)subview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self addConstraint:centerYConstraint];
}

- (void)resetSubViewWidthEqualToSuperView:(UIView *)subView
{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    BOOL isCellView = [self superview] && [[self superview] isKindOfClass:[UITableViewCell class]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:isCellView ? 20 : 0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0
                                                      constant:CGRectGetHeight(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:CGRectGetMinY(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:CGRectGetMinX(subView.frame)]];
}

- (void)resetSubViewSizeEqualToSuperView:(UIView *)subView
{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:CGRectGetMinY(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:CGRectGetMinX(subView.frame)]];
}

- (void)alignLeftSubview:(UIView *)subView withLeftPadding:(CGFloat)LeftPadding bottomPadding:(CGFloat)bottomPadding
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0
                                                      constant:CGRectGetWidth(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0
                                                      constant:CGRectGetHeight(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-bottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:LeftPadding]];
}

- (void)alignRightSubview:(UIView *)subView withRightPadding:(CGFloat)rightPadding bottomPadding:(CGFloat)bottomPadding
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0
                                                      constant:CGRectGetWidth(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0
                                                      constant:CGRectGetHeight(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-bottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:-rightPadding]];
}

- (void)alignRightSubview:(UIView *)subView withRightPadding:(CGFloat)rightPadding topPadding:(CGFloat)topPadding
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0
                                                      constant:CGRectGetWidth(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0
                                                      constant:CGRectGetHeight(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:topPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:-rightPadding]];
}

- (void)alignCenterSubview:(UIView *)subView withBottomPadding:(CGFloat)bottomPadding
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0
                                                      constant:CGRectGetWidth(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0
                                                      constant:CGRectGetHeight(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-bottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
}

- (void)alignCenterSubview:(UIView *)subView withTopPadding:(CGFloat)TopPadding
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0
                                                      constant:CGRectGetWidth(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0
                                                      constant:CGRectGetHeight(subView.frame)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:TopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
}

////为iOS8用户重置界面大小
//- (void)resetViewFrameWithSize:(CGSize)size isLandscapeMode:(BOOL)isLandscapeMode
//{
//    if (isLandscapeMode && (size.height > size.width)) {
//        self.frame = CGRectMake(0, 0, size.height, size.width);
//    }
//}

@end

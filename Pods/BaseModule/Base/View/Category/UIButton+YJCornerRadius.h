//
//  UIButton+YJCornerRadius.h
//  YouShaQi
//
//  Created by Lee on 2018/5/2.
//  Copyright © 2018年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (YJCornerRadius)

- (void)setImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius;
- (void)setBackgroundImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius;

@end

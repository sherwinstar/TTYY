//
//  UIImage+YJCornerRadius.h
//  YouShaQi
//
//  Created by Lee on 2018/5/2.
//  Copyright © 2018年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YJCornerRadius)

- (UIImage *)imageWithCornerRadius:(CGFloat)radius;

- (UIImage *)imageWithClipImageSize:(CGSize)size;
@end

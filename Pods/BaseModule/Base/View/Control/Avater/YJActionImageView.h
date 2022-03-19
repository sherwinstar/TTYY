//
//  YJActionImageView.h
//  YouShaQi
//
//  Created by Lee on 2018/6/15.
//  Copyright © 2018 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

DEPRECATED_MSG_ATTRIBUTE("use: YJSActionImgView")
@interface YJActionImageView : UIImageView

@property (nonatomic, assign) CGFloat cornerRadius;
- (void)addTarget:(id)target action:(SEL)action;

@end

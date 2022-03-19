//
//  UIImageView+YJAvatarView.m
//  YouShaQi
//
//  Created by 郁玉涛 on 2019/8/28.
//  Copyright © 2019 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#import "UIImageView+YJAvatarView.h"
#import "UIImage+YJCornerRadius.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "CustomImageUtils.h"
#import "UIView+FrameConvenience.h"

@implementation UIImageView (YJAvatarView)

- (void)setAvatarViewWithString:(NSString *)string{
    [self yy_setImageWithURL:[NSURL URLWithString:string]
                               placeholder:[CustomImageUtils getDefaultLightAvatar]
                                   options:YYWebImageOptionSetImageWithFadeAnimation|YYWebImageOptionIgnoreFailedURL
                                completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                    if (!image) return ;
                                    //该方法取名和系统方法一样 imageWithSize 但是还是会先调用类别的 会出现image为nil的情况
                                    UIImage *mapImage = [image imageWithClipImageSize:CGSizeMake(self.size.width, self.size.width)];
                                    if (mapImage) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.image = mapImage;
                                            [self setNeedsDisplay];
                                            
                                        });
                                    }else{
                                        NSLog(@"image--exception");
                                    }
                                    
                                }];
}

@end

//
//  SvGifView.h
//  SvGifSample
//
//  Created by maple on 3/28/13.
//  Copyright (c) 2013 smileEvday. All rights reserved.
//
//  QQ: 1592232964


#import <UIKit/UIKit.h>

@interface SvGifView : UIView

@property (nonatomic, copy) void(^didAnimationStop)();

/*
 * @brief desingated initializer
 */
- (id)initWithCenter:(CGPoint)center fileURL:(NSURL*)fileURL;

/// 设置动画时长
- (void)setAnimationDuration:(CGFloat)duration;

/*
 * @brief start Gif Animation
 */
- (void)startGif;

- (void)startGifWithLoopCount:(NSInteger)loopCount;

/*
 * @brief stop Gif Animation
 */
- (void)stopGif;

/*
 * @brief get frames image(CGImageRef) in Gif
 */
+ (NSArray*)framesInGif:(NSURL*)fileURL;


@end

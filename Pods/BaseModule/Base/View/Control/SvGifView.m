//
//  SvGifView.m
//  SvGifSample
//
//  Created by maple on 3/28/13.
//  Copyright (c) 2013 smileEvday. All rights reserved.
//
//  QQ: 1592232964

#import "SvGifView.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/CoreAnimation.h>

/*
 * @brief resolving gif information
 */
void getFrameInfo(CFURLRef url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *gifWidth, CGFloat *gifHeight)
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
    
    // get frame count
    size_t frameCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < frameCount; ++i) {
        // get each frame
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:(id)frame];
        CGImageRelease(frame);
        
        // get gif info with each frame
        NSDictionary *dict = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        //        NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
        
        // get gif size
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
        
        CFRelease(dict);
    }
    
    if (gifSource) {
        CFRelease(gifSource);
    }
}

@interface SvGifView() <CAAnimationDelegate> {
    NSMutableArray *_frames;
    NSMutableArray *_frameDelayTimes;
    
    CGFloat _totalTime;         // seconds
    CGFloat _width;
    CGFloat _height;
    CGFloat _animationDuration; // animation duration
}

@end

@implementation SvGifView


- (id)initWithCenter:(CGPoint)center fileURL:(NSURL*)fileURL;
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        _frames = [[NSMutableArray alloc] init];
        _frameDelayTimes = [[NSMutableArray alloc] init];
        
        _width = 0;
        _height = 0;
        
        if (fileURL) {
            getFrameInfo((CFURLRef)fileURL, _frames, _frameDelayTimes, &_totalTime, &_width, &_height);
        }
        
        self.frame = CGRectMake(0, 0, _width/2, _height/2);
        self.center = center;
    }
    
    return self;
}

- (void)dealloc
{
    [_frames release];
    [_frameDelayTimes release];
    
    [super dealloc];
}

+ (NSArray*)framesInGif:(NSURL *)fileURL
{
    NSMutableArray *frames = [NSMutableArray array];
    NSMutableArray *delays = [NSMutableArray array];
    
    getFrameInfo((CFURLRef)fileURL, frames, delays, NULL, NULL, NULL);
    
    return frames;
}

- (void)setAnimationDuration:(CGFloat)duration {
    _animationDuration = duration;
}

- (void)startGif {
    [self startGifWithLoopCount:100];
}
- (void)startGifWithLoopCount:(NSInteger)loopCount
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray *times = [NSMutableArray array];
    CGFloat currentTime = 0;
    int count = _frameDelayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / _totalTime)]];
        currentTime += [[_frameDelayTimes objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        [images addObject:[_frames objectAtIndex:i]];
    }
    
    [animation setValues:images];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    //animation.duration = _totalTime;
    CGFloat duration = 1.50;
    if (_animationDuration > 0) {
        duration = _animationDuration;
    }
    animation.duration = duration;
    animation.delegate = self;
    animation.repeatCount = loopCount;
    animation.removedOnCompletion = NO;
    
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
}

- (void)stopGif
{
    [self.layer removeAllAnimations];
    [self.layer.contents removeAllAnimations];
    if (self.didAnimationStop) {
        self.didAnimationStop();
    }
}

// remove contents when animation end
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self.layer removeAllAnimations];
        [self.layer.contents removeAllAnimations];
        if (self.didAnimationStop) {
            self.didAnimationStop();
        }
    }
}

//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}


@end



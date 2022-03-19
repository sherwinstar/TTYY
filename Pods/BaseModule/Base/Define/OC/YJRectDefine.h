//
//  YJRectDefine.h
//  YouShaQi
//
//  Created by Nevermore on 2020/4/15.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

#ifndef YJRectDefine_h
#define YJRectDefine_h

///phone、pad赋不同的值
#define KZSIPhoneIpadMargin(iPhoneMargin, iPadMargin) (Screen_IPAD ? iPadMargin : iPhoneMargin)

#pragma mark - ------------------ 屏幕机型相关 ------------------
//是否是iphone4S屏幕
#define Screen_iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//是否是iphone5屏幕
#define Screen_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//是否是iphone6屏幕
#define Screen_iPhone6 (Screen_IPHONE && (MAX(Screen_Width, Screen_Height)) == 667.0)
//是否是iphone6Plus屏幕
#define Screen_iPhone6P (Screen_IPHONE && (MAX(Screen_Width, Screen_Height)) == 736.0)
//iPhoneX / iPhoneXS屏幕
#define Screen_iPhoneXS (Screen_Width == 375.f && Screen_Height == 812.f ? YES : NO)
//iPhoneXR / iPhoneXSMax屏幕
#define  Screen_iPhoneXSMax_XR (Screen_Width == 414.f && Screen_Height == 896.f ? YES : NO)

#pragma mark - ------------------ Frame适配相关 ------------------
//屏幕宽度
#define Screen_Width ([[UIScreen mainScreen] bounds].size.width)
//屏幕高度
#define Screen_Height ([[UIScreen mainScreen] bounds].size.height)
//底部安全高度
#define Screen_SafeBottomHeight ([UIDevice safeAreaInsets].bottom)
//顶部安全高度
#define Screen_SafeTopHeight (Screen_FullScreenIphone ? 24.0f : 0)
//是否是pad
#define Screen_IPAD ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
//是否是手机
#define Screen_IPHONE ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//是否全面屏
#define Screen_FullScreen [UIDevice safeAreaInsets].bottom > 0.0 ? YES : NO
//是否全面屏手机
#define Screen_FullScreenIphone (Screen_IPHONE && Screen_FullScreen)
//是否全面屏pad
#define Screen_FullScreenIpad (Screen_IPAD && Screen_FullScreen)
//是否320宽度手机
#define Screen_320Width ([UIScreen mainScreen].bounds.size.width == 320.0)
//Nav高度
#define Screen_NavHeight (64.0f + Screen_SafeTopHeight)
//NavItem的Y值
#define Screen_NavItemY (Screen_FullScreenIphone ? 44.0f : 20.0f)
//tabbar高度
#define Screen_TabHeight (49.0f + Screen_SafeBottomHeight)

#define Screen_NavVideoHeight (Screen_FullScreenIphone ? 44 : 0)
#define Screen_BigViewHeight (Screen_NavHeight + (Screen_IPAD ? 16 : 0))


//基于375等比放大
#define Screen_Adjust375(Value) Screen_Width * (Value) / 375.0
//iPad等比放大
#define Screen_IPadMultiply(originValue) (Screen_IPAD ? 1.4f * (originValue) : (originValue))
#define Screen_IPadMinMultiply(originValue) (Screen_IPAD ? 1.2f * (originValue) : (originValue))
#define Screen_IPadMaxMultiply(originValue) (Screen_IPAD ? 1.6f * (originValue) : (originValue))
//iPad等比放大、iPhone基于375等比放大
#define Screen_IPadAdjustMultiply(originValue) (Screen_IPAD ? 1.4f * (originValue) : (Screen_Adjust375(originValue)))

#define Screen_SelfViewWidth CGRectGetWidth(self.view.frame)
#define Screen_SelfViewHeight CGRectGetHeight(self.view.frame)
#define Screen_SeparatorHeight (1.0f/[UIScreen mainScreen].scale)
#define Screen_ShelfEditMenuWidth Screen_IPadMultiply(228)
#define Screen_SecondNavHeight (Screen_FullScreenIphone ? 133 : 109)
///iPad阅读器toolview的宽度
static CGFloat const Screen_PadReadToolWidth = 375.0;

#endif /* YJRectDefine_h */

//
//  YJUIDefine.h
//  YouShaQi
//
//  Created by yun on 2017/11/3.
//  Copyright © 2017年 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//


#ifndef YJUIDefine_h
#define YJUIDefine_h

#import "UIColor+HexTransform.h"
#import "YJRectDefine.h"

#pragma mark - ------------------ color相关 ------------------
#define Color_RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define Color_RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define Color_Hex(a) [UIColor colorWithRGBHex:a]
#define Color_HexA(c, a) [UIColor colorWithRGBHex:c alpha:a]

//---------------------------颜色常量-----------------------
#define Color_White [UIColor whiteColor]
#define Color_Black [UIColor blackColor]
#define Color_ThemeRed Color_Hex(0xEE4745)
#define Color_ThemeYellow Color_Hex(0xFFDA12)
#define Color_ThemeWhite Color_Hex(0xffffff)
#define Color_SliderRed Color_RGBA(238, 71, 69, 1.0)
#define Color_PayBlack Color_Hex(0x222121)// 阅读器购买黑色
#define Color_PayRedBg Color_Hex(0xB12F2D)// 阅读器购买红色
#define Color_SeparateLine Color_Hex(0xEBEBF0)
#define Color_GlobalSeparator Color_RGB(200, 200, 200)
#define Color_TableSeparator Color_Hex(0xEBEBF0)
#define Color_SubTitleColor Color_Hex(0xa3a3a3)
#ifdef TARGET_ZSSQ
#define Color_Theme = Color_ThemeRed
#else
#define Color_Theme = Color_ThemeYellow
#endif

#pragma mark - ------------------ 字体相关 ------------------
///英文字体
#define Font_Bebas(a) [UIFont fontWithName:@"BEBAS" size:a]
///系统
#define Font_System(a) [UIFont systemFontOfSize:a]
///加粗
#define Font_Bold(a) [UIFont boldSystemFontOfSize:a]
///介于加粗和最粗之间
#define Font_Heavy(a) [UIFont systemFontOfSize:a weight:UIFontWeightHeavy]
///半粗
#define Font_Semibold(a) [UIFont systemFontOfSize:a weight:UIFontWeightSemibold]
///介于常规和半粗之间
#define Font_Medium(a) [UIFont systemFontOfSize:a weight:UIFontWeightMedium]
///介于常规和细之间
#define Font_Light(a) [UIFont systemFontOfSize:a weight:UIFontWeightLight]
///常规字体
#define Font_Regular(a) [UIFont systemFontOfSize:a weight:UIFontWeightRegular]
///最粗
#define Font_Black(a) [UIFont systemFontOfSize:a weight:UIFontWeightBlack]

///系统
#define Font_System_IPadMul(a) [UIFont systemFontOfSize:Screen_IPadMultiply(a)]
///加粗
#define Font_Bold_IPadMul(a) [UIFont boldSystemFontOfSize:Screen_IPadMultiply(a)]
///介于加粗和最粗之间
#define Font_Heavy_IPadMul(a) [UIFont systemFontOfSize:Screen_IPadMultiply(a) weight:UIFontWeightHeavy]
///半粗
#define Font_Semibold_IPadMul(a) [UIFont systemFontOfSize:Screen_IPadMultiply(a) weight:UIFontWeightSemibold]
///介于常规和半粗之间
#define Font_Medium_IPadMul(a) [UIFont systemFontOfSize:Screen_IPadMultiply(a) weight:UIFontWeightMedium]
///介于常规和细之间
#define Font_Light_IPadMul(a) [UIFont systemFontOfSize:Screen_IPadMultiply(a) weight:UIFontWeightLight]
///常规字体
#define Font_Regular_IPadMul(a) [UIFont systemFontOfSize:Screen_IPadMultiply(a) weight:UIFontWeightRegular]
///phone、pad设置不同值
#define Font_System_Margin(iPhoneFont, iPadFont) (Screen_IPAD ? [UIFont systemFontOfSize:iPadFont] : [UIFont systemFontOfSize:iPhoneFont])
#define Font_Medium_Margin(iPhoneFont, iPadFont) (Screen_IPAD ? Font_Medium(iPadFont) : Font_Medium(iPhoneFont))


#endif /* YJUIDefine_h */

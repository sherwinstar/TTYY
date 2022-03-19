//
//  YJSUIDefine.swift
//  YouShaQi
//
//  Created by Nevermore on 2020/4/21.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

//MARK: - color相关
//TODO: 两个生成color的，另一个可能不行，合并到主工程里再看
public func sColor_RGB(_ r: UInt, _ g: UInt, _ b: UInt) -> UIColor {
    return sColor_RGBA(r, g, b, 1.0)
}

public func sColor_RGBA(_ r: UInt, _ g: UInt, _ b: UInt, _ a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
}

public func Color_Hex(_ hexStr: String) -> UIColor {
    return Color_Hex(hexStringToInt(from: hexStr))
}

public func Color_Hex(_ rgbValue: UInt) -> UIColor {
    return Color_HexA(rgbValue, alpha: 1.0)
}

public func Color_HexA(_ hexStr: String, alpha: CGFloat) -> UIColor {
    return Color_HexA(hexStringToInt(from: hexStr), alpha: alpha)
}

public func Color_HexA(_ rgbValue: UInt, alpha: CGFloat) -> UIColor {
    let r = (rgbValue & 0xFF0000) >> 16
    let g = (rgbValue & 0x00FF00) >> 8
    let b = rgbValue & 0x0000FF
    return sColor_RGBA(r, g, b, alpha)
}

fileprivate func hexStringToInt(from:String) -> UInt {
    let str = from.replacingOccurrences(of: "#", with: "").uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
        if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
            sum -= 7
        }
    }
    return UInt(sum)
}

//---------------------------颜色常量-----------------------
public let Color_ThemeRed = Color_Hex(0xEE4745)
public let Color_ThemeYellow = Color_Hex(0xFFDA12)
public let Color_ThemeWhite = Color_Hex(0xffffff)
public let Color_SliderRed = sColor_RGBA(238, 71, 69, 1)
public let Color_PayBlack = Color_Hex(0x222121)// 阅读器购买黑色
public let Color_PayRedBg = Color_Hex(0xB12F2D)// 阅读器购买红色
public let Color_SeparateLine = Color_Hex(0xEBEBF0)
public let Color_GlobalSeparator = sColor_RGB(2200, 200, 200)
public let Color_TableSeparator = Color_Hex(0xEBEBF0)
public let Color_SubTitleColor = Color_Hex(0xa3a3a3)
#if TARGET_ZSSQ
public let Color_Theme = Color_ThemeRed
#else
public let Color_Theme = Color_ThemeYellow
#endif

//MARK: - 字体相关
//系统字体
public func Font_System(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size)
}

public func Font_System_IPadMul(_ size: CGFloat) -> UIFont {
    return Font_System(Screen_IPadMultiply(size))
}

//介于常规和半粗之间
public func Font_Medium(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
}

public func Font_Medium_IPadMul(_ size: CGFloat) -> UIFont {
    return Font_Medium(Screen_IPadMultiply(size))
}

//半粗
public func Font_Semibold(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
}

public func Font_Semibold_IPadMul(_ size: CGFloat) -> UIFont {
    return Font_Semibold(Screen_IPadMultiply(size))
}

//加粗
public func Font_Bold(_ size: CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: size)
}

public func Font_Bold_IPadMul(_ size: CGFloat) -> UIFont {
    return Font_Bold(Screen_IPadMultiply(size))
}

//介于加粗和最粗之间
public func Font_Heavy(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.heavy)
}

public func Font_Heavy_IPadMul(_ size: CGFloat) -> UIFont {
    return Font_Heavy(Screen_IPadMultiply(size))
}

//最粗
public func Font_Black(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.black)
}

//介于常规和细之间
public func Font_Light(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.light)
}

//细
public func Font_Thin(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.thin)
}

public func Font_Regular(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
}

public func Font_Regular_IPadMul(_ size: CGFloat) -> UIFont {
    return Font_Heavy(Screen_IPadMultiply(size))
}

//英文字体
public func Font_Bebas(_ size: CGFloat) -> UIFont {
    return UIFont(name: "BEBAS", size: size) ?? Font_System(size)
}


//phone、pad设置不同值
public func Font_Heavy_Both(phoneSize: CGFloat, padSize: CGFloat) -> UIFont {
    let size = Screen_IPAD ? padSize : phoneSize
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.heavy)
}

public func Font_Bold_Both(phoneSize: CGFloat, padSize: CGFloat) -> UIFont {
    let size = Screen_IPAD ? padSize : phoneSize
    return UIFont.boldSystemFont(ofSize: size)
}

public func Font_Semibold_Both(phoneSize: CGFloat, padSize: CGFloat) -> UIFont {
    let size = Screen_IPAD ? padSize : phoneSize
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
}

public func Font_Medium_Both(phoneSize: CGFloat, padSize: CGFloat) -> UIFont {
    let size = Screen_IPAD ? padSize : phoneSize
    return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
}

public func Font_System_Both(phoneSize: CGFloat, padSize: CGFloat) -> UIFont {
    let size = Screen_IPAD ? padSize : phoneSize
    return UIFont.systemFont(ofSize: size)
}

//MARK: - iphone ipad设置不同值
public func KZSIPhoneIpadMargin(_ iPhoneMargin:CGFloat, _ iPadMargin:CGFloat) -> CGFloat {
    if Screen_IPAD {
        return iPadMargin
    } else {
        return iPhoneMargin
    }
}



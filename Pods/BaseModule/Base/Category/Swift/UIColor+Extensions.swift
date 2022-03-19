//
//  UIColor+Extensions.swift
//  YouShaQi
//
//  Created by 杨旭 on 2019/9/5.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

/// 获取颜色：红绿蓝参数范围是 0-255
public func Color_RGB(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
    return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
}

/// 获取指定透明度的颜色：红绿蓝参数范围是 0-255
public func Color_RGBA(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
}

extension UIColor {
    /// 根据十六进制数获得颜色
    class public func yjs_colorWithRGBHex(hex: UInt32) -> UIColor {
        return yjs_colorWithRGBHex(hex: hex, alpha: 1.0)
    }
    
    /// 根据十六进制数获得颜色
    class public func yjs_colorWithRGBHex(hex: UInt32, alpha: CGFloat) -> UIColor {
        let r = CGFloat((hex >> 16) & 0xFF)
        let g = CGFloat((hex >> 8) & 0xFF)
        let b = CGFloat((hex) & 0xFF)
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    /// 根据十六进制数的字符串获得颜色
    class public func yjs_colorWithRGBHexString(hexString: String) -> UIColor {
        //#ffffff 转换成 FFFFFF
        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        var alpha: CGFloat = 1.0
        var red: CGFloat = 255.0
        var blue: CGFloat = 255.0
        var green: CGFloat = 255.0
        
        switch colorString.count {
        case 3: // #RGB
            alpha = 1.0
            red = yjs_colorComponent(string: colorString, start: 0, length: 1)
            green = yjs_colorComponent(string: colorString, start: 1, length: 1)
            blue = yjs_colorComponent(string: colorString, start: 2, length: 1)
        case 4: // #ARGB
            alpha = yjs_colorComponent(string: colorString, start: 0, length: 1)
            red = yjs_colorComponent(string: colorString, start: 1, length: 1)
            green = yjs_colorComponent(string: colorString, start: 2, length: 1)
            blue = yjs_colorComponent(string: colorString, start: 3, length: 1)
        case 6: // #RRGGBB
            alpha = 1.0
            red = yjs_colorComponent(string: colorString, start: 0, length: 2)
            green = yjs_colorComponent(string: colorString, start: 2, length: 2)
            blue = yjs_colorComponent(string: colorString, start: 4, length: 2)
        case 8: // #AARRGGBB
            alpha = yjs_colorComponent(string: colorString, start: 0, length: 2)
            red = yjs_colorComponent(string: colorString, start: 2, length: 2)
            green = yjs_colorComponent(string: colorString, start: 4, length: 2)
            blue = yjs_colorComponent(string: colorString, start: 6, length: 2)
        default:
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private class func yjs_colorComponent(string: String, start: Int, length: Int) -> CGFloat {
        let startIndex = string.index(string.startIndex, offsetBy: start)
        let endIndex = string.index(string.startIndex, offsetBy: start + length)
        let subString = string[startIndex..<endIndex]
        let fullHex = length == 2 ? subString : subString + subString
        let scan = Scanner(string: String(fullHex))
        var hexComponent: CUnsignedInt = 0
        scan.scanHexInt32(&hexComponent)
        return CGFloat(hexComponent) / 255
    }

}

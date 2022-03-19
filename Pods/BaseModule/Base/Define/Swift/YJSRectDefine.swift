//
//  YJSRectDefine.swift
//  YouShaQi
//
//  Created by Nevermore on 2020/4/20.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

//MARK: - 屏幕机型相关
//是否是iphone4S
public let Screen_iPhone4s = Screen_Height != 480 ? false : true
// 是否是iPhone5
public let Screen_iPhone5 = Screen_Height == 568 && Screen_Width == 320
//是否是iphoneSE
public let Screen_iPhoneSE = Screen_Height != 568 ? false : true
//是否是iphone6
public let Screen_iPhone6 = Screen_Height != 667 ? false : true
//是否是iphone6P
public let Screen_iPhone6P = Screen_Height != 736 ? false : true
//是否是iphoneX
public let Screen_iPhoneX = (Screen_FullScreenIphone) ? true :false
//iPhoneXR / iPhoneXSMax屏幕
public let Screen_iPhoneXSMax_XR = (Screen_Width == 414 && Screen_Height == 896) ? true : false

//MARK: - 公用适配Frame相关
//屏幕的宽
public let Screen_Width = UIScreen.main.bounds.size.width
//屏幕的高
public let Screen_Height = UIScreen.main.bounds.size.height
//底部安全高度
public let Screen_SafeBottomHeight : CGFloat =  UIDevice.yjs_safeAreaInsets().bottom
//顶部安全高度
public let Screen_SafeTopHeight : CGFloat = (Screen_FullScreenIphone) ? 24.0 : 0.0

//是否是pad
public let Screen_IPAD = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
//是否是手机
public let Screen_IPHONE = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone)
//是否全面屏
public let Screen_FullScreen = UIDevice.yjs_safeAreaInsets().bottom > 0.0 ? true : false
//是否全面屏手机
public let Screen_FullScreenIphone = Screen_IPHONE && Screen_FullScreen
//是否全面屏pad
public let Screen_FullScreenIpad = Screen_IPAD && Screen_FullScreen
//Nav高度
public let Screen_NavHeight : CGFloat = (Screen_FullScreenIphone) ? 88.0 : 64.0
public let Screen_BigNavHeight : CGFloat = Screen_IPAD ? 80.0 : Screen_NavHeight
//NavItem的Y值
public let Screen_NavItemY : CGFloat = (Screen_FullScreenIphone) ? 44.0 : 20.0
//底部tabbar高度
public let Screen_TabHeight : CGFloat = 49.0 + Screen_SafeBottomHeight
// 去掉了底部安全区域的屏幕高度
public let Screen_Content_Height : CGFloat = Screen_iPhoneX ? (UIScreen.main.bounds.size.height - 34.0) : UIScreen.main.bounds.size.height

/// 适配小屏幕：基于375等比放大
public func Screen_Adjust375(_ originValue: CGFloat) -> CGFloat {
    return Screen_Width * originValue / 375.0
}

/// iPad 1.4 倍放大
public func Screen_IPadMultiply(_ originValue: CGFloat) -> CGFloat {
    if Screen_IPAD {
        return 1.4 * originValue
    } else {
        return originValue
    }
}

/// iPad 1.2 倍放大
public func Screen_IPadMinMultiply(_ originValue: CGFloat) -> CGFloat {
    if Screen_IPAD {
        return 1.2 * originValue
    } else {
        return originValue
    }
}

/// iPad 1.6 倍放大
public func Screen_IPadMaxMultiply(_ originValue: CGFloat) -> CGFloat {
    if Screen_IPAD {
        return 1.6 * originValue
    } else {
        return originValue
    }
}

/// 屏幕适配：iPad等比放大 iPhone基于375放大
public func Screen_IPadAdjustMultiply(_ originValue: CGFloat) -> CGFloat {
    if Screen_IPAD {
        return 1.4 * originValue
    } else {
        return Screen_Adjust375(originValue)
    }
}

//MARK: - 部分私用Frame相关  -  用到的自行加注释说明
public let Screen_PadReadToolWidth : CGFloat = 375.0
public let Screen_NavVideoHeight : CGFloat = (Screen_FullScreen ? 44 : 0)
public let Screen_BigViewHeight : CGFloat = (Screen_NavHeight + (Screen_IPAD ? 16 : 0))
public let Screen_SeparatorHeight : CGFloat = (1.0 / UIScreen.main.scale)
public let Screen_ShelfEditMenuWidth : CGFloat = Screen_IPadMultiply(228)
public let Screen_SecondNavHeight : CGFloat = (Screen_FullScreen ? 133 : 109)
public func Screen_SelfViewWidth(_ view: UIView) -> CGFloat {
    return view.frame.size.width
}
public func Screen_SelfViewHeight(_ view: UIView) -> CGFloat {
    return view.frame.size.height
}

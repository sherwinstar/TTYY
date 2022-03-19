//
//  UIApplication+TYInfo.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/20.
//

import Foundation

extension UIApplication {
    static func getTabbarVC() -> TYTabBarVC? {
        guard let window = UIApplication.getWindow() else { return nil }
        if let tabbar = window.rootViewController as? TYTabBarVC {
            return tabbar
        } else if let nav = window.rootViewController as? UINavigationController {
            return nav.children.first { $0 is TYTabBarVC } as? TYTabBarVC
        } else {
            return nil
        }
    }
}

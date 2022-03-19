//
//  YJSWebModule.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/4.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation

fileprivate(set) var kModuleWebProtocols: [YJSWebToModuleProtocol.Type]!
fileprivate(set) var kUserModuleWebProtocol: YJSWebUserInfoProtocol.Type!

@objc public class WebModule: NSObject {
    @objc public static func startWebService(moduleProtocols: [YJSWebToModuleProtocol.Type], userProtocol: YJSWebUserInfoProtocol.Type) {
        kModuleWebProtocols = moduleProtocols
        kModuleWebProtocols.append(WebToWeb.self)
        kUserModuleWebProtocol = userProtocol
    }
}

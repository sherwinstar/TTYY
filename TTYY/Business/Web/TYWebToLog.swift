//
//  TYWebToLog.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/13.
//

import UIKit
import YJSWebModule
import BaseModule

class TYWebToLog: NSObject {
    // 通用的
    var callback: WebCallBack?
    var context: YJSWebContext?
    var webItem: YJSWebItem?
    weak var webVC: YJSWebContentVC?
    
    required init(webVC: YJSWebContentVC) {
        self.webVC = webVC
        super.init()
    }
}

extension TYWebToLog: YJSWebToModuleProtocol {
    static var moduleIdentifier: String {
        "bi"
    }
    
    func canHandleWebItem(webItem: YJSWebItem) -> Bool {
        let handled = ["setSensorsUserBehavior"].contains(webItem.funcName)
        return handled
    }
    
    func handle(webItem: YJSWebItem, context: YJSWebContext, callback: @escaping WebCallBack) {
        self.webItem = webItem
        self.context = context
        self.callback = callback
        
        switch webItem.funcName {
        case "setSensorsUserBehavior":
            //STA: H5-全埋点
            var sensor = webItem.seParams(.params)
            guard let event = sensor.getStrValue("event") else { return }
            sensor.removeValue(forKey: "event")
            TYSTAHelper.track(eventName: event, properties: sensor)
        default:
            break
        }
    }
}

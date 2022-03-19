//
//  TYOnlineParamsModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/19.
//

import UIKit
import KakaJSON

class TYOnlineParamsModel: Convertible, Decodable, Encodable {
    var thirdSDK: TYOnlineThirdSDK?
    var logSwitch: TYLogSwitch?
    required init() {}
    
    func setupDefaultValue() {
        thirdSDK = TYOnlineThirdSDK()
        logSwitch = TYLogSwitch()
    }
}

class TYOnlineThirdSDK: Convertible, Decodable, Encodable {
    /// 听云SDK是否可用
    var tingyunSDKEnable: Bool = true
    /// 神策是否可用
    var staEnable: Bool = true
    required init() {}
}

class TYLogSwitch:  Convertible, Decodable, Encodable {
    // 50207的接口是否上传
    var logBaseBehaviorEnabled: Bool = true
    required init() {}
}

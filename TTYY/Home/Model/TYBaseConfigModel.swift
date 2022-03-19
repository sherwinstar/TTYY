//
//  TYBaseConfigModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/3.
//

import KakaJSON

struct TYBaseConfigModel: Convertible {
    /// 参数
    var name: String = ""
    /// 参数值
    var value: String = ""
    /// 参数键
    var key: String = ""
    // 排序，数字越大越靠后
    var sort: Int = 0
}

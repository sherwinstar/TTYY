//
//  TYShopRecommendType.swift
//  TTYY
//
//  Created by Shaolin Zhou on 2021/11/3.
//

import UIKit
import KakaJSON

struct TYShopRecommendType: Convertible {
    var name: String = ""
    /// 1 联盟商品 2 非联盟商品
    var id: Int = 0
}

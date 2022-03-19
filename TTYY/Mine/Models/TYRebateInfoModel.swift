//
//  TYRebateInfoModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/8/11.
//
import KakaJSON

class TYRebateInfoModel: Convertible {
    /// 用户ID
    var userId: String = ""
    /// 历史累计进账金额 返利+贝壳币兑换
    var money: Float = 0
    /// 历史累计返利金额
    var rebateMoney: Float = 0
    /// 历史累计节省金额，原价 - 实付价
    var allSaveMoney: Float = 0
    /// 账户金额
    var allMoney: Float = 0
    /// 已经下单，可以返利，但是没返利的金额
    var forecastMoney: Float = 0
    /// 账户余额
    var remainMoney: Float = 0
    /// 提现等操作， 从账户中冻结的金额
    var freezeMoney: Float = 0
    /// 总贝壳币
    var allConch: Int = 0
    /// 可以提现贝壳币
    var remainConch: Int = 0
    /// 冻结贝壳币
    var freezeConch: Int = 0
    required init() {}
}

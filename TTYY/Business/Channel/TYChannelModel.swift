//
//  TYChannelModel.swift
//  TTYY
//
//  Created by YJPRO on 2021/9/29.
//

import Foundation
import KakaJSON

class TYChannelModel: Convertible, Decodable, Encodable {
    /// 1-设备未点击广告 2-设备标识有效正常返回结果值 3-设备点击广告但点击时间超出72小时
    var attributionCode = 0
    /// 设备激活时间 单位:ms
    var activeTime = ""
    /// 渠道ID
    var channelId = ""
    /// 渠道名
    var channelName = ""
    /// 书籍ID
    var bookId = ""
    /// 场景类型 1-阅读器 2-书籍详情页 3-H5短链接 4-书架
    var sceneType = ""
    /// 场景类型值 当sceneType=1时此值为章节序号，当sceneType=3时此值为H5短链接
    var typeValue = ""
    ///商户ID
    var merchantId = ""
    ///商户名称
    var merchantName = ""
    ///计划ID-子渠道
    var planId = ""
    ///内部计划编号-子渠道
    var planNumber = ""
    ///广告点击时间
    var planClickTs = ""
    
    /// ip+ua匹配的渠道ID
    var uaChannelId = ""
    /// ip+ua匹配的渠道名
    var uaChannelName = ""
    /// ip+ua匹配的点击时间 单位:ms
    var uaClickTs = ""
    /// ip+ua匹配的场景类型 1-阅读器 2-书籍详情页 3-H5短链接 4-书架
    var uaSceneType = ""
    /// ip+ua匹配的书籍ID
    var uaBookId = ""
    /// ip+ua匹配的场景值类型 当sceneType=1时此值为章节序号，当sceneType=3时此值为H5短链接
    var uaTypeValue = ""
    
    var bcId = "" //bookId_channelId
    required init() {
    }
    
    
    /// 判断是否是ip+ua
    /// - Returns: true:使用ip+ua， false：使用原来的
    func getUAJump() -> Bool {
        let notUA = !channelId.isBlank && channelId != "-1"
        let ua = !uaChannelId.isBlank && uaChannelId != "-1"
        if notUA && ua {
            // 两个都不为空
            if uaClickTs.compare(planClickTs) == .orderedAscending {
                return false
            } else {
                return true
            }
        } else if notUA {
            return false
        } else if ua {
            return true
        }
        return false
    }
    
    func getBCID() -> String {
        if getUAJump() {
            return uaBookId + "_" + uaChannelId
        } else {
            return bcId
        }
    }
    
    func getSceneType() -> String {
        if getUAJump() {
            return uaSceneType
        } else {
            return sceneType
        }
    }
    
    func getBookId() -> String {
        if getUAJump() {
            return uaBookId
        } else {
            return bookId
        }
    }
    
    func getTypeValue() -> String {
        if getUAJump() {
            return uaTypeValue
        } else {
            return typeValue
        }
    }
}

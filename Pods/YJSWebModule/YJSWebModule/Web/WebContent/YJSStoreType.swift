//
//  StoreType.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/5.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import BaseModule

@objc public enum YJSStoreType: Int {
    case none // 默认值，为了适配OC
    case bookstore // 书城 WebStoreTypeBookStoreTag
    case monthly // 包月专区 WebStoreTypeMonthlyStoreTag
    case ranking // 排行 WebStoreTypeRankingTag
    case rankingList // 排行详情页 WebStoreTypeRankingListTag
    case booklist // 书单 WebStoreTypeBooklistTag
    case booklistDetail // 书单详情页 WebStoreTypeBooklistDetailTag
    case category // 分类 WebStoreTypeCategoryTag
    case free // 免费专区 WebStoreTypeExclusiveTag
    /*
     老版本对于Exclusive有误解：
     客户端定义              h5定义    意义
     Exclusive            explore   免费专区
     RecommendedSelect   exclusive  专属推荐// 这个标签的来历应该是：原来的专属推荐还有个类似选择偏好的页面，后来没有了
     RecommendedList  客户端专用，h5不用 专属推荐
     */
    case cartoon // 漫画 WebStoreTypeComicTag
    case push // 推送 WebStoreTypePushTag
    case exclusive // 专属推荐 WebStoreTypeRecommendedListTag/WebStoreTypeRecommendedSelectTag
    case taskcenter // 任务中心 WebStoreTypeTaskCenterTag
    case newuserwelfare // 新用户福利 WebStoreTypeNewUserWelfare
    case monthpay // 购买包月 原来版本中没有对应的
    case bigGodMaster //大神个人主页-H5
    case bigGodTopicDetail //大神文章详情页-H5
    case bigGodUserSubscrib //个人中心-用户订阅
    case bigGodUserCollect //个人中心-用户订阅
    // WebStoreTypeSubViewTag, WebStoreTypeShituTag 去掉了
    case ttyyNoNav // 天天有余，标记没有导航栏
    
    public static func fromRaw(_ str: String) -> YJSStoreType {
        switch str {
        case "bookstore": return .bookstore
        case "monthly": return .monthly
        case "ranking": return .ranking
        case "rankingList": return .rankingList
        case "booklist": return .booklist
        case "booklistDetail": return .booklistDetail
        case "category": return .category
        case "free": return .free
        case "cartoon": return .cartoon
        case "push": return .push
        case "exclusive": return .exclusive
        case "taskcenter": return .taskcenter
        case "newuserwelfare": return .newuserwelfare
        case "monthpay": return .monthpay
        case "master": return .bigGodMaster
        case "topicDetail": return .bigGodTopicDetail
        default:
            return .none
        }
    }
    
    public var url: String? {
        var params: [String : String] = [:]
        var path: String
        let findParam = "发现".addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""
        let p = "pageFrom=\(findParam)"
        switch self {
        case .bookstore:
            path = "/explore"
        case .monthly:
            #if TARGET_FTZS
            path = "/v2/vip2.html"
            params = ["id" : "f3ac27f5c72542b897a8d9ad0632ab32"]
            #else
            path = "/v2/vip4.html"
            params = ["posCode" : "C1", "id" : "f3ac27f5c72542b897a8d9ad0632ab32", "pageFrom" : findParam]
            #endif
        case .ranking:
            #if TARGET_FTZS
            path = "/fantuan/ranking2.html"
            #else
            path = "/v2/ranking2.html"
            #endif
        case .rankingList: // 原来的版本里就没有写
            return nil
        case .booklist:
            #if TARGET_FTZS
            path = "/fantuan/booklist2.html"
            params = ["posCode" : "C1"]
            #else
            path = "/v2/booklist2.html"
            params = ["pageFrom" : findParam]
            #endif
        case .booklistDetail: // 需要拼接id
            #if TARGET_FTZS
            path = "/fantuan/bookListDetail2.html"
            #else
            path = "/v2/bookListDetail.html"
            #endif
        case .category:
            #if TARGET_FTZS
            path = "fantuan/category.html"
            params = ["posCode" : "S1"]
            #else
            path = "/v2/category.html"
            #endif
        case .free:
            path = "/v2/free2.html"
            params = ["posCode" : "C1", "id" : "a4c7b8b791044c9abc413c277dd0b2f3", "pageFrom" : findParam]
        case .cartoon:
            path = "/v2/cartoon.html"
            params = ["id" : "5a04005af958913a73b2ecdc", "pageFrom" : findParam]
        case .push: // 原来的版本里就没有写
            return nil
        case .exclusive: // 专属推荐
            path = "/v2/exclusiveList.html"
        case .taskcenter: // URL由外部指定
            return nil
        case .newuserwelfare:
            path = "/v2/welfare2.html"
            params = ["appversion" : UIApplication.yjs_versionShortCode()]
        case .monthpay:
            #if TARGET_FTZS
            path = "/fantuan/vipCenter.html"
            #else
            path = "/v2/vipCenterForIos2.html"
            #endif
        case .none:
            return nil
        case .bigGodMaster:
            return nil //URL由外部指定 大神的url由邓伟自己决定-但是需要此标记
        case .bigGodTopicDetail:
            return nil //URL由外部指定 大神的url由邓伟自己决定-但是需要此标记
        case .bigGodUserSubscrib:
            return nil //URL由外部指定 大神的url由邓伟自己决定-但是需要此标记
        case .bigGodUserCollect:
            return nil //URL由外部指定 大神的url由邓伟自己决定-但是需要此标记
        case .ttyyNoNav:
            return nil // URL由外部指定 天天有余的url由谢枫自己决定-但是需要此标记
        }
        return YJSUrlComposer.h5(path: path, params: params)?.absoluteString
    }
}

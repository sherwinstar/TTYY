//
//  YJSLanguage.swift
//  BaseModule
//
//  Created by Admin on 2020/9/4.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import YYCache

public var languageHelper: YJSLanguageHelper = YJSLanguageHelper()

//MARK: - 给OC用的
@objc public class YJSLanguageHelper: NSObject {
    private let cache = YYCache(name: "appsetting")
    private var convertor: YJSLanguageConvertor?
    
    /// 初始化时确定语言
    override init() {
        super.init()
        let traditional = languageType.isTraditional()
        if traditional != isTraditional {
            saveToCahce(isTraditional: traditional)
        }
    }
    
    /// 是否是繁体模式
    @objc public static var isTraditional: Bool {
        languageHelper.isTraditional
    }
    
    /// 获取语言类型名称
    @objc public static var languageTypeTitle: String {
        languageHelper.languageType.title
    }
    
    /// 简繁模式发生变化的通知名
    @objc public static var traditionalChangedNotificationName: Notification.Name {
        Notification.Name(rawValue: "kZSTraditionalModeChangeNotification")
    }
    
    /// 切换简繁模式
    @objc public static func triggleTraditionalMode() {
        languageHelper.changeTraditional(to: !isTraditional)
    }
    
    /// 切换语言类型
    @objc public static func changeLanguageType(to type: YJSLanguageType) {
        languageHelper.changeLanguageType(to: type)
    }
    
    /// 翻译
    @objc public static func translate(str: String?) -> String {
        languageHelper.translate(str: str)
    }
}

//MARK: - 核心代码
extension YJSLanguageHelper {
    /// 是否是繁体模式。副作用：如果 cache 中没有存，就调用初始化方法
    public var isTraditional: Bool {
        guard let cacheValue = isTraditionalInCache else {
            return initTraditionalMode()
        }
        return cacheValue
    }
    
    /// 语言类型。副作用：如果 cache 中没有存，就调用初始化方法
    public var languageType: YJSLanguageType {
        guard let type = typeInCahce else {
            return initLanguageType()
        }
        return type
    }
    
    /// 修改语言类型，用来让用户主动调用的，副作用：会引起简繁模式变化
    public func changeLanguageType(to type: YJSLanguageType) {
        if type == languageType {
            return
        }
        saveToCahce(languageType: type)
        changeTraditional(to: type.isTraditional(), synToLanguage: false)
    }
    
    /// 修改简繁模式
    /// - Parameters:
    ///   - isTraditional: 是繁体吗
    ///   - synToLanguage: 如果为true，就会引起语言类型变化，如果为false，不会引起语言类型变化。用户修改简繁体时 synToLanguage 要为 true，用户修改语言类型时，调用 changeLanguageType，changeLanguageType 调用本方法时，synToLanguage 要为false
    public func changeTraditional(to isTraditional: Bool, synToLanguage: Bool = true) {
        let old = self.isTraditional
        if synToLanguage {
            changeLanguageType(to: isTraditional ? .traditional : .simplified)
        }
        saveToCahce(isTraditional: isTraditional)
        if old != isTraditional {
            NotificationCenter.default.post(name: Self.traditionalChangedNotificationName, object: nil)
        }
    }
    
    /// 翻译文本
    public func translate(str: String?) -> String {
        if isTraditional {
            var convertor = self.convertor ?? YJSLanguageConvertor()
            self.convertor = convertor
            return convertor.s2t(str)
        }
        return str ?? ""
    }
}

//MARK: - 缓存操作
extension YJSLanguageHelper {
    // 键定义
    private static var isTraditionalKey: String { "TraditionalMode" }
    private static var languageTypeKey: String { "kZSLanguageTypeCacheKey" }
    
    /// 获取 cache 中的值，没有副作用
    private var typeInCahce: YJSLanguageType? {
        if let rawValue = (cache?.object(forKey: Self.languageTypeKey) as? NSNumber)?.intValue {
            return YJSLanguageType(rawValue: rawValue)
        }
        return nil
    }
    private var isTraditionalInCache: Bool? {
        (cache?.object(forKey: Self.isTraditionalKey) as? NSNumber)?.boolValue
    }
    
    /// 获取 UserDefault 中的老值，没有副作用
    private var typeInUserDefault: YJSLanguageType? {
        if var rawValue = (UserDefaults.standard.value(forKey: Self.languageTypeKey) as? NSNumber)?.intValue {
            rawValue = rawValue - 1 // 原来定义的枚举是从1开始的，新定义的枚举是从0开始的，需要减去1
            return YJSLanguageType(rawValue: rawValue)
        }
        return nil
    }
    private var traditionalInUserDefault: Bool? {
        return (UserDefaults.standard.value(forKey: Self.isTraditionalKey) as? NSNumber)?.boolValue
    }
    
    /// 保存到 cache 中，没有副作用
    private func saveToCahce(isTraditional: Bool) {
        cache?.setObject(NSNumber(booleanLiteral: isTraditional), forKey: Self.isTraditionalKey)
    }
    
    private func saveToCahce(languageType: YJSLanguageType) {
        cache?.setObject(NSNumber(integerLiteral: languageType.rawValue), forKey: Self.languageTypeKey)
    }
    
    /*
     1. 语言类型和简繁模式都要适配老版本
     2. 外部对 初始化简繁模式/语言类型 的调用顺序不确定
     （1）只有确定了语言类型，才能确定简繁模式
     （2）所以在初始化简繁转换时，如果语言类型还没有确定，会先初始化语言类型
     （3）初始化语言类型的时候不会处理简繁模式，因为等调用到的时候，简繁模式自己会初始化
     */
    
    //MARK: - 初始化
    /// 初始化简繁模式。副作用：这个初始化过程可能会引起语言类型的初始化，过程稍微有些复杂
    private func initTraditionalMode() -> Bool {
        // 1. 如果 UserDefault 中有，就更新到 cache 中
        if let isTraditional = traditionalInUserDefault { // 从老版本中取
            saveToCahce(isTraditional: isTraditional)
            return isTraditional
        }
        // 2. 否则，先获取语言类型
        // 取语言类型：先从 cache 中取，再从 UserDefault 中取
        let languageType = typeInCahce ?? initLanguageType()
        
        // 3. 根据语言类型确定简繁模式，并同步到 cache 中
        let isTraditional = languageType.isTraditional()
        saveToCahce(isTraditional: isTraditional)
        
        return isTraditional
    }
    
    /// 初始化语言类型：优先取 UserDefault 中的，否则默认值为 跟随系统，这个初始化过程没有副作用
    private func initLanguageType() -> YJSLanguageType {
        let type: YJSLanguageType = typeInUserDefault ?? YJSLanguageType.followSystem
        saveToCahce(languageType: type)
        return type
    }
}

//MARK: - 语言类型枚举
@objc public enum YJSLanguageType: Int {
    case simplified
    case traditional
    case followSystem
    
    func isTraditional() -> Bool {
        switch self {
        case .simplified:
            return false
        case .traditional:
            return true
        case .followSystem:
            guard let lans = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], let lan = lans.first else {
                return false
            }
            // 如果不是中文，就使用简体中文
            if !lan.contains("zh-") || lan.contains("-Hans") {
                return false
            } else {
                let traditionalIds = ["-Hant", "-CHT", "-TW", "-HK"]
                return traditionalIds.first {
                    lan.contains($0)
                    } != nil
            }
        }
    }
    
    public var title: String {
        switch self {
        case .simplified:
            return "简体中文"
        case .followSystem:
            return "跟随系统"
        case .traditional:
            return "繁体中文"
        }
    }
}

//MARK: - 简繁转换器
public struct YJSLanguageConvertor {
    // 担心误触发 YJSLanguageConvertor 的初始化，所以我把耗时的操作放在第一次使用 maps 时
    private static var maps: [Character : Character]!
    
    /// 简体翻译成繁体，副作用：如果发现简繁对照表还没有初始化，会调用初始化操作
    public mutating func s2t(_ content: String?) -> String {
        guard let content = content else {
            return ""
        }
        if Self.maps == nil {
            setupMaps()
        }
        let components: [Character] = content.reduce(into: []) { (result, c) in
            let replaced = Self.maps[c] ?? c
            result.append(replaced)
        }
        return String(components)
    }
    
    /// 初始化简繁对照表
    mutating private func setupMaps() {
        let str = Bundle.main.path(forResource: "ts", ofType: "tab")
            .flatMap { (path) in
            try? String(contentsOfFile: path, encoding: .utf8)
            }
        guard let origin = str else {
            Self.maps = [:]
            return
        }
        var value: Character? = nil
        let st: [Character : Character] = origin.reduce(into: [:]) { (result, c) in
            if let stValue = value {
                result[c] = stValue
                value = nil
            } else {
                value = c
            }
        }
        Self.maps = st
    }
}

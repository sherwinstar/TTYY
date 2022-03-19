//
//  TYCacheHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/8.
//

import UIKit
import Cache

class TYCacheHelper: NSObject {
    static let shared = TYCacheHelper()
    
    private lazy var stringCache : Storage<String> = {
        let diskConfig = DiskConfig(name: "com.ttyy.cache.String")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let cache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: String.self))
        return cache
    }()
    
    private lazy var intCache : Storage<Int> = {
        let diskConfig = DiskConfig(name: "com.ttyy.cache.Int")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let cache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Int.self))
        return cache
    }()
    
    private lazy var boolCache : Storage<Bool> = {
        let diskConfig = DiskConfig(name: "com.ttyy.cache.Bool")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 256, totalCostLimit: 256)
        let cache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Bool.self))
        return cache
    }()
    
    /// 存储字符串
    class func cacheString(value: String, for key: String) {
        if !value.isBlank {
            try? TYCacheHelper.shared.stringCache.setObject(value, forKey: key)
        }
    }
    
    /// 删除字符串
    class func removeString(for key: String) {
        try? TYCacheHelper.shared.stringCache.removeObject(forKey: key)
    }

    
    /// 获取存储的字符串
    class func getCacheString(for key: String) -> String? {
        if key.isBlank {
            return nil
        }
        return try? TYCacheHelper.shared.stringCache.entry(forKey: key).object
    }
    
    /// 存储Int
    class func cacheInt(value: Int, for key: String) {
        try? TYCacheHelper.shared.intCache.setObject(value, forKey: key)
    }
    
    /// 获取存储的Int
    class func getCacheInt(for key: String) -> Int? {
        if key.isBlank {
            return nil
        }
        return try? TYCacheHelper.shared.intCache.entry(forKey: key).object
    }
    
    /// 存储Bool
    class func cacheBool(value: Bool, for key: String) {
        try? TYCacheHelper.shared.boolCache.setObject(value, forKey: key)
    }
    
    /// 获取存储的Bool
    class func getCacheBool(for key: String) -> Bool? {
        if key.isBlank {
            return nil
        }
        return try? TYCacheHelper.shared.boolCache.entry(forKey: key).object
    }
    
    
    // MARK: - 增加的便捷方法
    /// 获取搜索历史
    class func getHistoryKeyWordArray(for key: String) -> [String]? {
        if key.isBlank {
            return nil
        }
        let keywords = try? TYCacheHelper.shared.stringCache.entry(forKey: key).object
        if let list = keywords, !list.isBlank {
            let array = list.components(separatedBy: ",")
            return array
        }
        return nil
    }
    
    
    /// 存储复制过文字，分享过的商品ID
    /// - Parameter ids: 商品ID数组
    class func saveSharedGoodsIds(_ ids: [String]) {
        if ids.count <= 0 {
            return
        }
        let idsStr = ids.joined(separator: ",")
        TYCacheHelper.cacheString(value: idsStr, for: "saveSharedGoodsIds")
    }
    
    /// 获取商品ID数组
    class func getSharedGoodsIds() -> [String] {
        let ids = TYCacheHelper.getCacheString(for: "saveSharedGoodsIds") ?? ""
        if ids.isBlank {
            return []
        }
        let arr = ids.components(separatedBy: ",")
        return arr
    }
}

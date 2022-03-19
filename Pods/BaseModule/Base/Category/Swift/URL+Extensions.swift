//
//  URL+Extensions.swift
//  YouShaQi
//
//  Created by Beginner on 2019/9/12.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import UIKit

extension URL {
    /// 获取 query 字典
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems =   components.queryItems else { return nil }
        
        var items: [String: String] = [:]
        
        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        
        return items
    }
    
    /// 拼接参数
    public func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0, value: $1) })
        urlComponents.queryItems = items
        return urlComponents.url!
    }
    
    /// 获取 query 部分
    public func queryValue(for key: String) -> String? {
        let stringURL = self.absoluteString
        guard let items = URLComponents(string: stringURL)?.queryItems else { return nil }
        for item in items where item.name == key {
            return item.value
        }
        return nil
    }
}

//MARK: - 对字符串转义得到Url
extension URL {
    public static func encodeFrom(_ urlStr: String) -> URL? {
        if let encodedStr = urlStr.removingPercentEncoding?.yjs_queryEncodedURLString() {
            return URL(string: encodedStr)
        }
        return nil
    }
}

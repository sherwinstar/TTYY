//
//  WebString.swift
//  YouShaQi
//
//  Created by Admin on 2020/8/7.
//  Copyright © 2020 Shanghai YuanJu Network Technology Co.Ltd. All rights reserved.
//

import Foundation
 
//MARK: - Web 字典
extension Dictionary {
    public func filterUnsupportValue() -> Self {
        return self.filter { item -> Bool in
            let value = item.value
            return value is String.Type || value is NSNumber.Type
        }
    }
}

//MARK: - Web 字符串
extension String {
    func parserToWebItem() -> YJSWebItem? {
        let matchResults = try? NSRegularExpression(pattern: "^jsbridge://(\\w+)(\\?)?", options: .caseInsensitive).firstMatch(in: self, options: .reportCompletion, range: NSRange(location: 0, length: self.count))
        guard let range1 = matchResults?.range(at: 1), let funcRange = Range(range1, in: self) else {
            return nil
        }
        let funcName = self[funcRange]
        var query: WebStrJson? = nil
        var params: WebJson? = nil
        if let range2 = matchResults?.range(at: 2) {
            let range2ToLast = NSRange(location: range2.location, length: self.count - range2.location)
            if let queryRange = Range(range2ToLast, in: self) {
                query = String(self[queryRange]).parserQuery()
                if let paramData = query?["param"]?.data(using: .utf8) {
                    params = (try? JSONSerialization.jsonObject(with: paramData, options: [])) as? WebJson
                }
            }
        }
        return YJSWebItem(funcName: String.init(funcName), query: query, param: params)
    }
    
    func parserQuery() -> WebStrJson {
        let queries = self.replacingOccurrences(of: "?", with: "").components(separatedBy: "&")
        return queries.reduce(into: [:]) { (result, next) in
            let keyValue = next.components(separatedBy: "=")
            if keyValue.count >= 2, let value = keyValue[1].removingPercentEncoding {
                result[keyValue[0]] = value
            }
        }
    }
}

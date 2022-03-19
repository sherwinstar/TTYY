//
//  Array+FTZSCategory.swift
//  YouShaQi
//
//  Created by YJMac-QJay on 23/7/2019.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation

//MARK: - 安全方法
extension Array {
    /// 安全地插入/获取指定位置元素
    ///
    ///     testArr[safely:1]
     public subscript (safely index: Int) -> Element? {
        get {// Get Index
            if (self.startIndex..<self.endIndex).contains(index) {
                return self[index]
            } else {
                return nil
            }
        }
        set {// Set Index
            if let newValue = newValue {
                if (self.startIndex ..< self.endIndex).contains(index) {
                    self[index] = newValue
                }
            }
        }
    }
}

//MARK: - 转成json字符串
extension Collection {
    /// 把数组转成 json 形式的字符串
    public func jsonString() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        if let jsonData = jsonData {
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } else {
            return nil
        }
    }
}

//MARK: - 便利方法
extension Array where Element: Equatable {
    /// 便利地删除数组某元素，要求元素实现了 Equatable 协议
    mutating public func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

//MARK: - 取指定类型 value
extension Dictionary {
    public func getStrValue(_ key: Key) -> String? {
        self[key] as? String
    }
    
    public func getIntValue(_ key: Key) -> Int? {
        self[key] as? Int
    }
    
    public func getBoolValue(_ key: Key) -> Bool? {
        self[key] as? Bool
    }
    
    public func getNumValue(_ key: Key) -> NSNumber? {
        self[key] as? NSNumber
    }
    
    public func getJsonValue(_ key: Key) -> [String : Any]? {
        self[key] as? [String : Any]
    }
}

//MARK: - 遍历，组合，变形
extension Sequence {
    public func doIn(_ loop: (Element) -> ()) {
        for item in self {
            loop(item)
        }
    }
}

extension Array {
    /// Array<A> + Array<B> -> Array<(A, B)>
    /// 把两个数组组合成一个数组，得到的数组的长度是两个源数组中长度最短的那个
    ///
    ///     let a = ["1", "2"]
    ///     let b = ["一", "二", "三"]
    ///     a.zip(b)
    ///     // [("1", "一"), ("2", "二")]
    /// - Parameter b: 源数组之一
    /// - Returns: 组合后的数组
    public func zip<B>(_ b: Array<B>) -> Array<(Element, B)> {
        let minCount = Swift.min(count, b.count)
        let zipped: [(Element, B)] = (0..<minCount).reduce(into: []) { (result, index) in
            let aElement = self[index]
            let bElement = b[index]
            result.append((aElement, bElement))
        }
        return zipped
    }
    
    /// 带索引的 forin
    public func iDoIn(_ loop: (Element, Int) -> ()) {
        var index = 0
        for item in self {
            loop(item, index)
            index += 1
        }
    }
    
    /// 带索引的 map
    public func iMap<T>(_ transform: (Element, Int) throws -> T) rethrows -> [T] {
        var index = 0
        return try map { (element) -> T in
            let result = try transform(element, index)
            index += 1
            return result
        }
    }
    
    /// 带索引的 flatMap
    public func iFlatMap<SegmentOfResult>(_ transform: (Element, Int) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        var index = 0
        return try flatMap { (element) -> SegmentOfResult in
            let result = try transform(element, index)
            index += 1
            return result
        }
    }
    
    /// 带索引的 compactMap
    public func iCompactMap<ElementOfResult>(_ transform: (Element, Int) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var index = 0
        return try compactMap { (element) -> ElementOfResult? in
            let result = try transform(element, index)
            index += 1
            return result
        }
    }
}

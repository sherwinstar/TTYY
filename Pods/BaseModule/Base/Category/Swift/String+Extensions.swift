//
//  String+Addition.swift
//  YouShaQi
//
//  Created by YJMac-QJay on 2/8/2019.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto
import CoreText

//MARK: - 定义字符串常量
extension String {
    //MARK: - 赚钱字符串
    public static let kHuYanText: String = String(data: Data(base64Encoded: "6LWa6ZKx") ?? Data(), encoding: .utf8) ?? ""
    //MARK: - 充值字符串
    public static let kRechargeText: String = String(data: Data(base64Encoded: "5YWF5YC8") ?? Data(), encoding: .utf8) ?? ""
}

//MARK: - 常用
extension String {
    /// 判断是否为空
    public var isBlank: Bool {
        if self.isEmpty {
            return true
        }
        
        if self.isKind(of: NSNull.self) {
            return true
        }
        
        if self == "(null)" {
            return true
        }
        
        if self == "null" {
            return true
        }
        
        let str = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if str.isEmpty {
            return true
        }
        
        return false
    }
    
    /// 简繁转换
    public func yjs_translateStr() -> String {
        languageHelper.translate(str: self)
    }
}

extension NSString {
    @objc public func yjs_translateStr() -> NSString {
        languageHelper.translate(str: self as String) as NSString
    }
}

//MARK: - 字符串截取
extension String {
    /// 不包含to
    public func sub(to: Int) -> String? {
        guard isVaild(to: to) else {
            return nil
        }
        let index: String.Index = self.index(startIndex, offsetBy: to)
        return String(self[..<index])
    }
    
    /// 包含from
    public func sub(from: Int) -> String? {
        guard isVaild(from: from) else {
            return nil
        }
        let index: String.Index = self.index(startIndex, offsetBy: from)
        return String(self[index ..< endIndex])
    }
    
    /// 包含from, 不包含to
    public func sub(from: Int, to: Int) -> String? {
        guard isVaild(to: to), isVaild(from: from), from <= to else {
            return nil
        }
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex..<endIndex])
    }
    
    private func isVaild(from: Int) -> Bool {
        from >= 0 && from < count
    }
    
    private func isVaild(to: Int) -> Bool {
        to >= 0 && to <= count
    }
    
    /// 截取出可显示出来的字符串
    /// - Parameters:
    ///   - inWidth: 指定的宽度
    ///   - maxLineCount: 最多行数
    ///   - font: 字体
    /// - Returns: 可显示出来的字符串
    public func substring(inWidth: CGFloat, maxLineCount: Int, using font: UIFont) -> String {
        guard !isEmpty else {
            return self
        }
        // 创建 coretext 对象
        var att = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font : font])
        let typesetter = CTTypesetterCreateWithAttributedString(att)
        
        var result: [String] = []
        var startIndex = 0 // 下面循环中处理字符串的范围
        var leftStr: String? = self // 剩下的字符串：下面循环中处理字符串
        
        while let left = leftStr,
              result.count < maxLineCount {
            // 计算这一行截断的位置
            let curLineCharCount: Int = CTTypesetterSuggestLineBreak(typesetter, startIndex, Double(inWidth))
            // 取这一行的字符串
            if let substring = left.sub(to: curLineCharCount) {
                result.append(substring)
            }
            // 为下一次循环做准备
            leftStr = left.sub(from: curLineCharCount)
            startIndex = startIndex + curLineCharCount
        }
        return result.toString(joinBy: "")
    }
    
    /// 截取出指定范围的字符串
    public func substring(fromStartStr start: String, toEndStr end: String) -> String? {
        guard let startRange = self.range(of: start),
              let endRange = self.range(of: end) else {
            return nil
        }
        return self.sub(from: startRange.upperBound.encodedOffset, to: endRange.lowerBound.encodedOffset)
    }
}

//MARK: - 转换为计数单位
extension String {
    /// 把数字转换成指定计数单位的字符串
    ///
    ///     let nums = [1, 12, 123, 1234, 12345, 123056, 1230567, 12305678, 123056789]
    ///     for num in nums {
    ///     let result = String.map(int: num, support: [.hundred, .thousand, .tenThousand, .hundredMillion], maxFloatBitCount: 2)
    ///     NSLog("数字%ld结果%@", num, result)
    ///     //        数字1结果1
    ///     //        数字12结果12
    ///     //        数字123结果1.23百
    ///     //        数字1234结果1.23千
    ///     //        数字12345结果1.23万
    ///     //        数字123056结果12.31万
    ///     //        数字1230567结果123.06万
    ///     //        数字12305678结果1230.57万
    ///     //        数字123056789结果1.23亿
    /// - Parameters:
    ///   - int: 将要转换的数字
    ///   - yields: 支持的计数单位
    ///   - maxFloatBitCount: 保留小数点后的位数
    /// - Returns: 数字的字符串表示
    public static func map(int: Int, support yields: CountYield, maxFloatBitCount: Int) -> String {
        let min = yields.min
        if int < min { // 小于最小值的直接返回，不需要拼接单位
            return String(format: "%d", int)
        }
        let minYield = yields.minYield
        for yield in CountYield.orderedAll.reversed() { // 遍历所有的单位，直到找到小数位不为0的
            // 如果支持这个单位（比如：支持百和万，不支持千），并且计算没有出错
            guard yields.contains(yield),
                  let seperators = int.leftMove(bit: yield.bit) else {
                continue
            }
            // 最后一个单位了，必须要有返回值了
            if minYield == yield && seperators.afterDot.isEmpty {
                return "\(seperators.beforeDot)\(yield.name)"
            }
            // beforeDot有0位，说明是类似0.1万这样的，不符合要求
            guard !seperators.beforeDot.isEmpty,
                  let float = Float("\(seperators.beforeDot).\(seperators.afterDot)") else {
                continue
            }
            // 不需要带小数时
            if maxFloatBitCount == 0 {
                return String(format: "%ld%@", Int(float), yield.name)
            }
            // 是否小数位后只有一位
            let oneBit = maxFloatBitCount == 1 || seperators.afterDot.count < 2
            let format = oneBit ? "%.1f%@" : "%.2f%@"
            return String(format: format, float, yield.name)
        }
        return String(format: "%d", int)
    }
}

//MARK: - 字符串计数单位变形
extension String {
    /// 过滤空白符号，包括空格、换行符、制表符
    public func filterSpace() -> String {
        self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
//    //将数字转化为以万为单位的字符串
//    static public func yj_cutNumToMiriade(num: Int) -> String {
//        if num < 10000 {
//            return String(format: "%d", num)
//        }
//        let hundred = num / 100
//        let miriade = num / 10000;
//        if hundred == miriade * 100 {
//            return String(format: "%d万", miriade)
//        }
//        let thousand = num / 1000;
//        if thousand == miriade * 10 {
//            return String(format: "%.1f万", Double(num) / 10000.0)
//        }
//        return String(format: "%.2f万", Double(num) / 10000.0);
//    }
//
//    //将数字转化为以亿为单位的字符串
//    static public func yj_cutNumToMillion(num: Int64) -> String {
//        var originStr = String(format: "%ld", num) as NSString
//        if originStr.length >= 5{
//            let floatStr = originStr.substring(with: NSMakeRange(originStr.length - 4, 1))
//            let intStr = originStr.substring(with: NSMakeRange(0, originStr.length - 4))
//            originStr = String(format:"%@.%@万",intStr,floatStr) as NSString;
//        }
//
//        if originStr.length >= 8{
//            let floatStr = originStr.substring(with: NSMakeRange(originStr.length - 7, 2))
//            let intStr = originStr.substring(with: NSMakeRange(0, originStr.length - 7))
//            originStr = String(format:"%@.%@亿",intStr,floatStr) as NSString;
//        }
//        return originStr as String;
//    }
    
//    //统计字数
//    public func yj_countWord() -> Int {
//        if self.isBlank {
//            return 0
//        }
//        var l = 0
//        var a = 0
//        var b = 0
//        for i in self.indices {
//            let c = self[i]
//            let intCha = c.toInt()
//            if isblank(Int32(intCha)) != 0 {
//                b += 1
//            } else if isascii(Int32(intCha)) != 0 {
//                a += 1
//            } else {
//                l += 1
//            }
//        }
//        if a == 0 && l == 0 {
//            return 0
//        }
//        let num = l + Int(ceilf(Float(Double(a+b)/2.0)))
//        return num
//    }
}

//MARK: - 字符串计时变形
extension String {
    /// 把seconds转换成 分钟:秒钟 样式
    public static func mapToXX2XXFormat(seconds: Int) -> String {
        let minute = String(format: "%02ld", seconds % 3600 / 60)
        let second = String(format: "%02ld", seconds % 60)
        return "\(minute):\(second)"
    }
}

//MARK: - 加密
extension String {
    /// MD5String
    public func yj_MD5String() -> String? {
        if self.isBlank {
            return ""
        }
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: 0)
        return String(format: hash as String)
    }

    /// 把图片数据md5，上传图片时需要
    public static func md5StringFromImage(image: UIImage) -> String {
        guard let imgData = image.jpegData(compressionQuality: 1),
            let rawPointer = imgData.withUnsafeBytes({ $0 }).baseAddress else {
            return ""
        }
        let count = Int(CC_MD5_DIGEST_LENGTH)
        let md: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: count)
        md.initialize(repeating: 0, count: count)
        CC_MD5(rawPointer, CC_LONG(imgData.count), md)
        let imageHash = NSString(format: "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 md[0], md[1], md[2], md[3], md[4], md[5], md[6], md[7], md[8], md[9], md[10], md[11], md[12], md[13], md[14], md[15])
        md.deinitialize(count: count)
        md.deallocate()
        return imageHash as String
    }

    /// 先 md5 再 base64 得到字符串
    public func yj_md5AndBase64Str() -> String? {
        if self.isBlank {
            return ""
        }
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        
        let base64 = Data(bytes: result, count: digestLen)
        let base64Str = base64.base64EncodedString(options: .lineLength64Characters)
        return base64Str
    }
}

//MARK: - URL 相关
extension String {
    /// urlEncode，会先解码再转码，以避免多次转码做成的问题
    public func yjs_queryEncodedURLString() -> String? {
        self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    public func yjs_allEncodedURLString() -> String? {
        #if TARGET_TTYY
        let allowed = CharacterSet(charactersIn: "!*'();@+$,[]").inverted
        return self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: allowed)
        #else
        let allowed = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
        return self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: allowed)
        #endif

    }
    
    /// 是否是 itunes 的链接
    public func isiTunesURL() -> Bool {
        !self.isBlank && self.contains("//itunes.apple.com")
    }
    
    /// 是否是 appstore 的链接
    public func isAppStoreURL() -> Bool {
        self.hasPrefix("itms-apps://")
    }
    
    /// 获取URL的参数字典
    public func getUrlParams() -> [String : String] {
        let components = self.yjs_queryEncodedURLString()
            .flatMap { NSURLComponents(string: $0) }
            .flatMap { $0.queryItems }
        guard let queryItems = components else {
            return [:]
        }
        return queryItems.reduce(into: [:]) { (result, item) in
            if let value = item.value {
                result[item.name] = value
            }
        }
    }
}

//MARK: - 文件名处理
extension String {
    /// 去掉沙盒地址的沙盒之前的部分，得到相对地址（因为沙盒部分会变，所以如果保存地址的话，不能保存沙盒部分的）
    public func yjs_removingHomeDirectory() -> String? {
        guard let homeDirectoryRange = self.range(of: NSHomeDirectory()) else {
            return nil
        }
        let upper = homeDirectoryRange.upperBound.encodedOffset
        return self.sub(from: upper)
    }
}

//MARK: - 格式判断
extension String {
    /// 判断是否为可用的手机号
    public func yj_isVaildMobile() -> Bool {
        let numberOfMatches = self.numberOfMatchesInString(string: self, pattern:"1[0-9]{10}")
        if numberOfMatches > 0 {
            return true
        } else {
            return false
        }
    }
    
    /// 判断是否为数字
    public func yj_isVaildNumber() -> Bool {
        let numberOfMatches = self.numberOfMatchesInString(string: self, pattern:"^[0-9]+$")
        if numberOfMatches > 0 {
            return true
        }
        return false
    }
    
    /// 判断是否是邮箱
    public func yj_isVaildEmail() -> Bool {
        let numberOfMatches = self.numberOfMatchesInString(string: self, pattern:"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        if numberOfMatches > 0 {
            return true
        }
        return false
    }
    
    private func numberOfMatchesInString(string:String,pattern:String) -> Int {
        let regex = try? NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        return regex?.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: string.count)) ?? 0
    }
}

//MARK: - 高度计算
extension String {
    /// 在指定的宽高下，计算文本宽高
    public func yjs_stringSize(fontSize: CGFloat, size: CGSize) -> CGRect {
        let attributes = [NSAttributedString.Key.font: Font_System(fontSize)]
        let rect: CGRect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect
    }
    
    /// 在指定的宽度下，计算文本宽高
    public func size(fixWidth: CGFloat, font: UIFont) -> CGSize {
        let rect = (self as NSString).boundingRect(with: CGSize(width: fixWidth, height: CGFloat(MAXFLOAT)), options: .truncatesLastVisibleLine, attributes: [:], context: nil)
        return rect.size
    }
    
    /// 在指定宽度、行数的范围下，计算文本的宽高
    public func size(fixWidth: CGFloat, numberOfLines: Int, font: UIFont) -> CGSize {
        let label = UILabel()
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.text = self
        label.font = font
        let labelSize = label.sizeThatFits(CGSize(width: fixWidth, height: CGFloat(MAXFLOAT)))
        let height = ceil(labelSize.height)
        let width = ceil(labelSize.width)
        return CGSize(width: width, height: height)
    }
}

//MARK: - 富文本字符串的创建
extension NSAttributedString {
    /// 生成 NSAttributedString 的便利方法
    public static func from(str: String, color: UIColor, font: UIFont) -> NSAttributedString {
        let attDic: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : color,
            NSAttributedString.Key.kern : 0
            ]
        let attStr = NSAttributedString(string: str, attributes: attDic)
        return attStr
    }
    
    /// 生成 NSAttributedString 的便利方法
    public static func from(str: String, color: UIColor, fontSize: CGFloat) -> NSAttributedString {
        let font = Font_System_IPadMul(fontSize)
        return from(str: str, color: color, font: font)
    }
    
    public static func from(str: String, attributes: [NSAttributedString.Key : Any], insertedImg: UIImage?, insertedIndex: Int, imgBoundsY: CGFloat) -> NSAttributedString {
        let att = NSMutableAttributedString(string: str.yjs_translateStr(), attributes: attributes)
        guard let img = insertedImg else {
            return att
        }
        let attachment = NSTextAttachment()
        attachment.image = img
        attachment.bounds = CGRect(x: 0, y: imgBoundsY, width: img.size.width, height: img.size.height)
        let attachementAtt = NSAttributedString(attachment: attachment)
        let index = max(0, insertedIndex)
        if (index >= str.count) {
            att.append(attachementAtt)
        } else {
            att.insert(attachementAtt, at: index)
        }
        return att;
    }
}

//MARK: - 特殊的统计字数的方法
extension String {
    /// 这个统计字数的方式很特别，只在社区用到了，其他地方不要用
    public func yjs_countWord() -> Int {
        if self.isBlank {
            return 0
        }
        var l = 0
        var a = 0
        var b = 0
        for i in self.indices {
            let c = self[i]
            let intCha = c.toInt()
            if isblank(Int32(intCha)) != 0 {
                b += 1
            } else if isascii(Int32(intCha)) != 0 {
                a += 1
            } else {
                l += 1
            }
        }
        if a == 0 && l == 0 {
            return 0
        }
        let num = l + Int(ceilf(Float(Double(a+b)/2.0)))
        return num
    }
}

//MARK: - 数字左移
extension Int {
    /// 把数字左移（也就是小数点右移）bit 位后，返回小数点前和小数点后的数字
    ///
    /// 因为 afterDot 的前面几位可能是0，所以不能返回 Int 类型
    /// - Parameters:
    ///   - bit: 位数
    /// - Returns: 小数点前后字符串
    fileprivate func leftMove(bit: Int) -> (beforeDot: String, afterDot: String)? {
        let origin = String(self)
        let seperatorIndex = origin.count - bit
        guard let beforeStr = origin.sub(to: seperatorIndex),
              let afterStr = origin.sub(from: seperatorIndex) else {
            return nil
        }
        var chars: NSMutableArray = afterStr.reversed().reduce(into: []) { (result, char) in
            if char == "0" && result.count == 0 {
                return
            }
            result.add(String(char))
        }
        guard let afterDotStr = (chars.reversed() as? NSArray)?.componentsJoined(by: "") else {
            return nil
        }
        return (beforeStr, afterDotStr)
    }
}

//MARK: - 计数单位
extension String {
    /// 计数单位
    public struct CountYield: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let hundred = CountYield(rawValue: 1 << 1) // 百
        public static let thousand = CountYield(rawValue: 1 << 2) // 千
        public static let tenThousand = CountYield(rawValue: 1 << 3) // 万
        // 十万/百万/千万
        public static let hundredMillion = CountYield(rawValue: 1 << 7) // 亿
        
        /// 当前 OptionSet 中包含的最小的计数单位的数值
        fileprivate var min: Int {
            if self.contains(.hundred) {
                return 100
            } else if self.contains(.thousand) {
                return 1000
            } else if self.contains(.tenThousand) {
                return 10000
            } else if self.contains(.hundredMillion) {
                return 100000000
            }
            return 0
        }
        
        /// 当前 OptionSet 中包含的最小的计数单位
        fileprivate var minYield: CountYield? {
            return CountYield.orderedAll.first {
                self.contains($0)
            }
        }
        
        /// 计数单位的数值
        fileprivate var int: Int {
            switch self {
            case .hundred:
                return 100
            case .thousand:
                return 1000
            case .tenThousand:
                return 10000
            case .hundredMillion:
                return 100000000
            default:
                return 0
            }
        }
        
        /// 计数单位的中文表示
        fileprivate var name: String {
            switch self {
            case .hundred:
                return "百"
            case .thousand:
                return "千"
            case .tenThousand:
                return "万"
            case .hundredMillion:
                return "亿"
            default:
                return ""
            }
        }
        
        /// 计数单位的位数-1
        fileprivate var bit: Int {
            switch self {
            case .hundred:
                return 2
            case .thousand:
                return 3
            case .tenThousand:
                return 4
            case .hundredMillion:
                return 8
            default:
                return 0
            }
        }
        
        /// 当前 OptionSet 的中文表示
        public var yields: String {
            var yields = ""
            for yield in CountYield.orderedAll {
                if self.contains(yield) {
                    yields = yields + yield.name
                }
            }
            return yields
        }
        
        /// 所有支持单位，要按照顺序写
        fileprivate static var orderedAll: [CountYield] {
            [.hundred, .thousand, .tenThousand, .hundredMillion]
        }
    }
}

extension Array where Element == String {
    public func toString(joinBy: String) -> String {
        reduce(into: "") { (result, substring) in
            if result.isEmpty {
                result.append(substring)
            } else {
                result.append("\(joinBy)\(substring)")
            }
        }
    }
}

extension Optional where Wrapped == String {
    public var isBlank: Bool {
        map { $0.isBlank } ?? true
    }
}

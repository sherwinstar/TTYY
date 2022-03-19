//
//  Date+Addition.swift
//  YouShaQi
//
//  Created by YJMac-QJay on 28/7/2019.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation

public enum YJSDateFormat: Int {
    /// yyyy-MM-dd'T'HH:mm:ss'.'SSS'Z'
    case format1 = 0
    /// yyyy-MM-dd HH:mm:ss
    case format2
    /// yyyy-MM-dd
    case format3
    /// MM-dd HH:mm
    case format4
    /// yyyy-MM-dd HH:mm:ss.SSSSSS
    case format5
    /// yyyy年MM月dd日
    case format6
    /// yyyyMMdd
    case format7
    /// yyyy-MM-dd HH:mm
    case format8
    /// yyyy-MM-dd HH时s
    case format9
}

extension Date {
    /// 是否是同一天
    public func yjs_isTheSameDay(otherDate: Date) -> Bool {
        let dateComponents = self.dateComponents()
        let otherDateComponents = otherDate.dateComponents()
        if otherDateComponents.year == dateComponents.year && otherDateComponents.month == dateComponents.month && otherDateComponents.day == dateComponents.day {
            return true
        }
        return false
    }
    
    /// 得到描述性的时间间隔字符串：XX分钟 / 小时 / 天 / 月 / 年前
    public var ago: String {
        let late = Double(self.timeIntervalSince1970)
        //设置0时区的时间
        let now = Double(Date().timeIntervalSince1970)
        var timeString = ""
        let cha = now - late
        if cha / 60 < 1 {
            timeString = "刚刚"
        } else if (cha / 60 > 1 && cha / 3600 < 1) {
            timeString = String(format: "%f", cha / 60)
            timeString = String(timeString.prefix(timeString.count-7))
            timeString =  String(format: "%@分钟前", timeString)
        } else if (cha / 3600 > 1 && cha / 86400 < 1) {
            timeString = String(format: "%f", cha / 3600)
            timeString = String(timeString.prefix(timeString.count-7))
            timeString =  String(format: "%@小时前", timeString)
        } else if (cha / 86400 > 1 && cha / 2592000 < 1) {
            timeString = String(format: "%f", cha / 86400)
            timeString = String(timeString.prefix(timeString.count-7))
            timeString =  String(format: "%@天前", timeString)
        } else if (cha / 2592000 > 1 && cha / 31536000 < 1) {
            timeString = String(format: "%f", cha / 2592000)
            timeString = String(timeString.prefix(timeString.count-7))
            timeString =  String(format: "%@月前", timeString)
        } else if (cha / 31536000 > 1) {
            timeString = String(format: "%f", cha / 31536000)
            timeString = String(timeString.prefix(timeString.count-7))
            timeString =  String(format: "%@年前", timeString)
        }
        return timeString
    }
    
    /// 是否是昨天
    public var isYesterDay: Bool {
        let currentDate = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let unitFlags = Set<Calendar.Component>([.year, .month, .day, .weekday, .hour, .minute, .second])
        let lastComps = calendar.dateComponents(unitFlags, from: self)
        let currentComps = calendar.dateComponents(unitFlags, from: currentDate)
        let lastYear = lastComps.year ?? 0
        let lastMonth = lastComps.month ?? 0
        let lastDay = lastComps.day ?? 0
        let currentYear = currentComps.year ?? 0
        let currentMonth = currentComps.month ?? 0
        let currentDay = currentComps.day ?? 0
        if (currentYear > lastYear || (currentYear == lastYear && currentMonth > lastMonth) || (currentYear == lastYear && currentMonth == lastMonth && currentDay > lastDay)) {
            return true;
        }
        return false;
    }
    
    /// 把 Date 转成时间标准格式（比如：2020-11-11 11:11）
    /// - Parameter dateFormat: 指定格式
    /// - Returns: 标准时间字符串
    public func stringValue(dateFormat: YJSDateFormat) -> String {
        let dateFormatter = DateFormatter.formatter(dateFormat)
        return dateFormatter?.string(from: self) ?? ""
    }
    
    /// 获得当前时区的时间
    public static func localZoneDate() -> Date {
        let date = Date()
        let zone = NSTimeZone.system
        let interval: TimeInterval = TimeInterval(zone.secondsFromGMT(for: date))
        return date.addingTimeInterval(interval)
    }
    
    /// 获得中国日历的 DateComponents
    private func dateComponents() -> DateComponents {
        let unitFlags = Set<Calendar.Component>([.year, .month, .day, .weekday, .hour, .minute, .second])
        return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents(unitFlags, from: self)
    }
}

//MARK: - 时间相关
extension String {
    /// 得到描述性的时间间隔字符串：XX分钟 / 小时 / 天 / 月 / 年前
    public var ago: String? {
        let date = self.toDate(dateFormat: .format1)
        return date?.ago
    }
    
    /// 是否是昨天
    public var isYesterDay: Bool? {
        let date = self.toDate(dateFormat: .format1)
        return date?.isYesterDay
    }
    
    /// 把字符串转换日期类型
    public func toDate(dateFormat: YJSDateFormat) -> Date? {
        let dateFormatter = DateFormatter.formatter(dateFormat)
        return dateFormatter?.date(from: self)
    }
}

// 常驻内存的 DateFormatter，因为在字典转model时，如果一直创建DateFormatter，太耗性能
fileprivate var globalDateFormatters: [DateFormatter?] = Array(repeating: nil, count: 9)

extension DateFormatter {
    /// 获得指定格式的 DateFormatter，这些 DateFormatter 是常驻内存的
    public static func formatter(_ format: YJSDateFormat) -> DateFormatter? {
        let index = format.rawValue
        guard globalDateFormatters.count > index else { // 安全判断
            return nil
        }
        // 如果已经生成过了
        if let dateFormatter = globalDateFormatters[index] {
            return dateFormatter
        }
        // 创建
        let enGBLocale = Locale(identifier: "en_GB")
        let utcZone = NSTimeZone.init(name: "UTC")
        let dateFormatter = DateFormatter()
        switch format {
        case .format1:
            dateFormatter.timeZone = utcZone as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.'SSS'Z'"
            break
        case .format2:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            break
        case .format3:
            dateFormatter.locale = enGBLocale
            dateFormatter.dateFormat = "yyyy-MM-dd"
            break
        case .format4:
            dateFormatter.dateFormat = "MM-dd HH:mm"
            break
        case .format5:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
            break
        case .format6:
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            break
        case .format7:
            dateFormatter.locale = enGBLocale
            dateFormatter.dateFormat = "yyyyMMdd"
            break
        case .format8:
            dateFormatter.locale = enGBLocale
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            break
        case .format9:
            dateFormatter.dateFormat = "yyyy-MM-dd HH时"
            break
        }
        globalDateFormatters[index] = dateFormatter
        return dateFormatter
    }
}

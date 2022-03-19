//
//  Error+Judge.swift
//  BaseModule
//
//  Created by Admin on 2020/9/8.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

extension Error {
    /// 是否是网络未连接的错误码
    public static func isNotConnectToInternet(errorCode: Int) -> Bool {
        // 这是iOS的错误码，不是 http 状态码
        [NSURLErrorNotConnectedToInternet].contains(errorCode)
    }
    
    /// 是否是 http 的状态码
    public static func isHttp(code: Int) -> Bool {
        // 这些都是 http 状态码
        let ranges: [ClosedRange<Int>] = [100...102, 200...207, 300...307, 400...417, 421...426, 449...449, 500...507, 509...510, 600...600]
        return ranges.contains { $0.contains(code) }
    }
    
    /// 是否是请求超时
    public static func isTimedOut(code: Int) -> Bool {
        [-999, -1001].contains(code)
    }

    /// 是否是网络错误
    public static func isNetworkError(code: Int) -> Bool {
        [NSURLErrorCannotConnectToHost,
         NSURLErrorNetworkConnectionLost,
         NSURLErrorNotConnectedToInternet].contains(code)
    }
    
    /// 是否是网络未连接的错误码
    public var isNotConnectToInternet: Bool {
        Self.isNotConnectToInternet(errorCode: (self as NSError).code)
    }
    
    /// 是否是 http 的状态码
    public var isHttpCode: Bool {
        Self.isHttp(code: (self as NSError).code)
    }
    
    /// 是否是请求超时
    public var isTimedOut: Bool {
        Self.isTimedOut(code: (self as NSError).code)
    }
    
    /// 是否是网络错误
    public var isNetworkError: Bool {
        Self.isNetworkError(code: (self as NSError).code)
    }
}

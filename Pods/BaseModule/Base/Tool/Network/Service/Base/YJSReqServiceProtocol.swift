//
//  YJSReqServiceProtocol.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation

public protocol YJSReqServiceProtocol {
    init()
    static func singleton() -> Bool
    static func share() -> Self
}

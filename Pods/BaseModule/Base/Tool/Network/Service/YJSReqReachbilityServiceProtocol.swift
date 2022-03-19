//
//  YJSReqReachbilityServiceProtocol.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation

protocol YJSReqReachbilityServiceProtocol: YJSReqServiceProtocol {
    func networkStatus() -> (status: ReachbilityStatus, statusStr: String)
    
    func startService()
    
    func isReachable() -> Bool
    
    func isReachableViaWiFi() -> Bool
    
    func isReachableViaCellular() -> Bool
}

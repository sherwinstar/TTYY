//
//  YJSReqDnsServiceProtocol.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/15.
//

import Foundation

protocol YJSReqDnsServiceProtocol: YJSReqServiceProtocol {
    func startService()
    func appendDNSHosts(_ hosts: [String])
    func updateDNSHosts(_ hosts: [String])
    func getHostIP(_ host: String) -> String
}

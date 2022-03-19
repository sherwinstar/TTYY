//
//  YJSReqPollHostServiceProtocol.swift
//  BaseModule
//
//  Created by Beginner on 2020/8/13.
//

import Foundation

protocol YJSReqPollHostServiceProtocol: YJSReqServiceProtocol {
    func getHostModel(forType hostType: YJSRequestHostType) -> YJSReqHostModel
    func pollNext(forType hostType: YJSRequestHostType)
    func update(_ hosts: [String]?, forHostType type: YJSRequestHostType)
}

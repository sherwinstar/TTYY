//
//  YJEncryptDataCenterSwift.swift
//  YJEncryptSwift
//
//  Created by YJPRO on 2020/12/8.
//

import UIKit

class YJEncryptDataCenterSwift: NSObject {
    static let share = YJEncryptDataCenterSwift()
    
    var originStr = ""
    var chapterEncKey = ""
    var tokenDecKey = ""
    var channelID = ""
    var token = ""
    var AppKeyDirectoryPath = ""
    var debugMode = false
}

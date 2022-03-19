//
//  YJSDBConnManager.swift
//  YouShaQi
//
//  Created by Beginner on 2019/10/16.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import SQLite

open class YJSDBConnManager {
    var sharedDBConnDic: [String: Connection]?
    var defaultDBConn: Connection?
    var queue = DispatchQueue(label: "com.youshaqi.dbConn")
    static let sharedInstance: YJSDBConnManager = {
        let instance = YJSDBConnManager()
        return instance
    }()
    
    open class func sharedDBConn(_ path: String) -> Connection? {
        if path.isBlank {
            return nil
        }
        guard let key = path.removingPercentEncoding else {
            return nil
        }
        var dbConn: Connection?
        YJSDBConnManager.sharedInstance.queue.sync {
            if YJSDBConnManager.sharedInstance.sharedDBConnDic == nil {
                YJSDBConnManager.sharedInstance.sharedDBConnDic = [String: Connection]()
            }
            if YJSDBConnManager.sharedInstance.sharedDBConnDic!.keys.contains(key) {
                dbConn = YJSDBConnManager.sharedInstance.sharedDBConnDic![key]
            } else {
                dbConn = autoReleaseDBConn(key)
                YJSDBConnManager.sharedInstance.sharedDBConnDic![key] = dbConn
            }
        }
        return dbConn
    }
    
    class func autoReleaseDBConn(_ path: String) -> Connection? {
        if path.isBlank {
            return nil
        }
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let absolutePath = "\(documentPath)/\(path).sqlite3"
        guard let dbConn = try? Connection(absolutePath) else {
            return nil
        }
        dbConn.busyTimeout = 5.0
        dbConn.busyHandler({ tries in
            if tries >= 5 {
                return false
            }
            return true
        })
        return dbConn
    }
}

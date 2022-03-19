//
//  YJSDBTable.swift
//  YouShaQi
//
//  Created by Beginner on 2019/10/16.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import SQLite

open class YJSDBTable {
    
    public lazy var dbConn: Connection? = {
        return YJSDBConnManager.sharedDBConn(configDBName() ?? "bookmark")
    }()
    
    public init() {
        createTable()
        addColumn()
    }
    
    public func obj() -> Table? {
        guard let tableName = configTableName() else {
            print("表名不能为空")
            return nil
        }
        return Table(tableName)
    }
    
    private func createTable() {
        guard let table = obj() else {
            return
        }
        let createSql = table.create(temporary: false, ifNotExists: true, withoutRowid: true) { t in
            configColumn(t: t)
        }
        do {
            let _ = try self.dbConn?.run(createSql)
        } catch {
            print("创建失败！")
        }
    }
    
    private func addColumn() {
        guard let table = obj() else {
            return
        }
        //追加列
        guard let addColSQLs = appendColumn(table: table) else {
            return
        }
        var excSQLs = [String]()
        //现在已经存在的列
        guard let allColumns = existAllColumns() else {
            return
        }
        //剔除已经存在的列
        for sql in addColSQLs {
            let words = sql.split(separator: "\"")
            if words.count < 4 {
                continue
            }
            if !allColumns.contains(String(words[3])) {
                excSQLs.append(sql)
            }
        }
        if excSQLs.count == 0 {
            return
        }
        guard let _ = try? self.dbConn?.execute(excSQLs.joined(separator: ";")) else {
            //print("失败")
            return
        }
        //print("成功")
    }
    
    //MARK: - -------------------------------------子类选择实现-------------------------------------
    
    /// 指定数据库名，如不指定，则默认使用：youshaqi
    ///
    /// - Returns: 数据库名
    open func configDBName() -> String? {
        return nil
    }
    
    //MARK: - -------------------------------------子类必须实现-------------------------------------
    
    /// 指定表名
    ///
    /// - Returns: 表名
    open func configTableName() -> String? {
        return nil
    }
    
    /// 配置列
    ///
    /// - Parameter t: 创建对象
    open func configColumn(t: TableBuilder) {
        
    }
    
    /// 后续版本追加列
    ///
    /// - Parameter table: 表对象
    /// - Returns: 追加SQL
    open func appendColumn(table: Table) -> [String]? {
        return nil
    }
    
    //MARK: - --------------------------------------内部方法--------------------------------------
    fileprivate func existAllColumns() -> [String]? {
        guard let tableName = configTableName() else {
            print("表名不能为空")
            return nil
        }
        guard let statement = try? dbConn?.prepare("PRAGMA table_info('\(tableName)')") else {
            return nil
        }
        var columnNames = [String]()
        while let row = statement.next() {
            columnNames.append(row[1] as! String)
        }
        
        return columnNames
    }
}

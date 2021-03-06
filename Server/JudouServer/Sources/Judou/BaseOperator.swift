//
//  BaseOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/19.
//

import Foundation
import PerfectMySQL

private let dataBaseName = "JUDOU"
private let host = "127.0.0.1"  //数据库IP
private let port = "3306"   //数据库端口
private let user = "root"   //数据库用户名
private let password = "8707gtt04CJSD,./"   //数据库密码

// MARK: - 连接MySql数据库的类
class SQLConnent {
    private var connect: MySQL! //用于操作MySql的句柄
    
    // MARK: - MySQL句柄单例
    private static var instance: MySQL!
    public static func shareInstance(dataBaseName: String) -> MySQL {
        if instance == nil {
            instance = SQLConnent(dataBaseName: dataBaseName).connect
        }
        
        return instance
    }
    
    private init(dataBaseName: String) {
        self.connectDataBase()
        self.selectDataBase(name: dataBaseName)
    }
    
    // MARK: - 连接数据库
    private func connectDataBase() {
        if connect == nil {
            connect = MySQL()
        }
        
        let connected = connect.connect(host: "\(host)", user: user, password: password)
        guard connected else {
            // 验证一下连接是否成功
            Utils.logError("连接数据库", "失败：\(connect.errorMessage())")
            return
        }
        
        Utils.logError("连接数据库", "成功")
    }
    
    // MARK: - 选择数据库Scheme
    ///
    /// - Parameter name: Scheme名
    private func selectDataBase(name: String) {
        // 选择具体的数据Schema
        guard connect.selectDatabase(named: name) else {
            Utils.logError("连接Schema", "错误代码：\(connect.errorCode()) 错误解释：\(connect.errorMessage())") 
            return
        }
        
        Utils.logError("连接Schema：", "\(name)成功")
    }
}
// MARK: - 操作数据库的基类
class BaseOperator {
    var mysql: MySQL {
        get {
            return SQLConnent.shareInstance(dataBaseName: dataBaseName)
        }
    }
    
    var responseJson: String! = "" 
}

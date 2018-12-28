//
//  AccountOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/19.
//

import Foundation

private let AES_ENCRYPT_KEY = "~!@#$%^&*()_+com.samcooperstudio.judou_1234567890-=,./"

class AccountOperator: BaseOperator {
    // MARK: - 手机号、昵称、用户id(三选一)是否存在
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - nickname: 昵称
    ///   - userId: 用户id
    /// - Returns: 0 不存在 1 已存在 2 查询失败
    private func checkAccount(mobile: String, nickname: String, userId: String) -> Int! {
        var statement = ""
        if mobile.count > 0 {
            statement = "select userId from \(accounttable) where mobile = '\(mobile)'"
        }
        
        if nickname.count > 0 {
            statement = "select userId from \(accounttable) where nickname = '\(nickname)'"
        }
        
        if userId.count > 0 {
            statement = "select userId from \(accounttable) where userId = '\(userId)'"
        }
        
        if statement.count == 0 {
            return 2
        }
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户是否存在", mysql.errorMessage())
            return 2
        } else {
            var isExist = 0
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                isExist = 0
            } else {
                isExist = 1
            }
            
            return isExist
        }
    }
    // MARK: - 根据手机号或用户id(二选一)获取用户信息
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - userId: 用户id
    /// - Returns: 返回JSON数据
    func getAccount(mobile: String, userId: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: userId)
        if accountStatus == 1 {
            var statement = ""
            let baseStatement = "userId, nickname, portrait, gender, birthday, mobile, date, status, level"
            // AES_DECRYPT(password, '\(AES_ENCRYPT_KEY)'),
            
            if mobile.count > 0 {
                statement = "select \(baseStatement) from \(accounttable) where mobile = '\(mobile)'"
            }
            
            if userId.count > 0 {
                statement = "select \(baseStatement) from \(accounttable) where userId = '\(userId)'"
            }
            
            if statement.count == 0 {
                return Utils.failureResponseJson("获取用户信息失败，缺少手机号或用户id(二选一)")
            }
            
            if mysql.query(statement: statement) == false {
                Utils.logError("获取用户信息", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("获取用户信息失败")
            } else {
                var dict: [String: Any] = [:]
                let results = mysql.storeResults()!
                var keys: [String] = baseStatement.components(separatedBy: ", ")
                
                results.forEachRow { (row) in
                    for idx in 0...row.count-1 {
                        let key = keys[idx]
                        dict["\(key)"] = row[idx] as Any
                    }
                }
                
                if dict["nickname"] as! String == "" {
                    dict["nickname"] = "User_\(dict["userId"] as! String)"
                }
                
                responseJson = Utils.successResponseJson(dict)
            }
        } else if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("获取用户信息失败")
        }
        
        return responseJson
    }
    // MARK: - 更新用户信息
    ///
    /// - Parameters:
    ///   - params: 需要修改参数内容 userId（用户id）必填
    /// - Returns: 返回JSON数据
    func updateAccount(params: [String: Any]) -> String {
        let userId: String = params["userId"] as! String
        
        let accountStatus = checkAccount(mobile: "", nickname: "", userId: userId)
        if accountStatus == 1 {
            var contentValue: [String] = []
            params.keys.forEach { (key) in
                if key != "userId" {
                    let value = params[key]
                    contentValue.append("\(key) = '\(value!)'")
                }
            }
            
            let statement = "update \(accounttable) set \(contentValue.joined(separator: ", ")) where userId = '\(userId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("更新用户信息", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("更新用户信息失败")
            } else {
                responseJson = self.getAccount(mobile: "", userId: userId)
            }
        } else if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("更新用户信息失败")
        }
        
        return responseJson
    }
    // MARK: - 重置密码
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - password: 新密码
    /// - Returns: 返回JSON数据
    func resetPassword(mobile: String, password: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 1 {
            let statement = "select AES_DECRYPT(password, '\(AES_ENCRYPT_KEY)') from \(accounttable) where mobile = '\(mobile)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("密码检验", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("密码检验失败")
            } else {
                let results = mysql.storeResults()!
                var passwd = ""
                results.forEachRow { (row) in
                    for idx in 0...row.count-1 {
                        passwd = row[idx]!
                        break
                    }
                }
                
                if passwd == password {
                    responseJson = Utils.failureResponseJson("新密码与原密码相同")
                } else {
                    let statement = "update \(accounttable) set password = AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)') where mobile = '\(mobile)'"
                    
                    if mysql.query(statement: statement) == false {
                        Utils.logError("重置密码", mysql.errorMessage())
                        responseJson = Utils.failureResponseJson("用户密码修改失败")
                    } else {
                        responseJson = Utils.successResponseJson("用户密码修改成功")
                    }
                }
            }
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("重置密码用户密码失败")
        }
        
        return responseJson
    }
    // MARK: - 账号密码登录
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - password: 密码
    /// - Returns: 返回JSON数据
    func passwordLogin(mobile: String, password: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 1 {
            let statement = "select AES_DECRYPT(password, '\(AES_ENCRYPT_KEY)') from \(accounttable) where mobile = '\(mobile)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("账号密码登录", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("登录失败")
            } else {
                let results = mysql.storeResults()!
                var passwd = ""
                results.forEachRow { (row) in
                    for idx in 0...row.count-1 {
                        passwd = row[idx]!
                        break
                    }
                }
                
                if passwd == password {
                    responseJson = self.getAccount(mobile: mobile, userId: "")
                } else {
                    responseJson = Utils.failureResponseJson("密码错误")
                }
            }
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("登录失败")
        }
        
        return responseJson
    }
    // MARK: - 注册用户名
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - password: 密码
    /// - Returns: 返回JSON数据
    func registerAccount(mobile: String, password: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            let nickname = ""
            let portrait = ""
            
            let current = Date()
            let birthday = Utils.dateToString(date: current, format: "yyyy-MM-dd")
            let date = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
            
            let values = "('\(mobile)', AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)'), ('\(nickname)'), ('\(portrait)'), ('\(birthday)'), ('\(date)'), ('1'))"
            let statement = "insert into \(accounttable) (mobile, password, nickname, portrait, birthday, date, level) values \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("创建用户", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("用户注册失败")
            } else {
                //返回登录信息
                responseJson = self.getAccount(mobile: mobile, userId: "")
            }
        } else if accountStatus == 1 {
            responseJson = Utils.failureResponseJson("该手机号码已被注册")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("用户注册失败")
        }
        
        return responseJson
    }
    
    func registerAdminAccount(mobile: String, password: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: "")
        if accountStatus == 0 {
            let nickname = ""
            let portrait = ""
            
            let current = Date()
            let birthday = Utils.dateToString(date: current, format: "yyyy-MM-dd")
            let date = Utils.dateToString(date: current, format: "yyyy-MM-dd HH:mm:ss")
            
            let values = "('\(mobile)', AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)'), ('\(nickname)'), ('\(portrait)'), ('\(birthday)'), ('\(date)'), ('0'))"
            let statement = "insert into \(accounttable) (mobile, password, nickname, portrait, birthday, date, level) values \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("创建用户", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("用户注册失败")
            } else {
                //返回登录信息
                responseJson = self.getAccount(mobile: mobile, userId: "")
            }
        } else if accountStatus == 1 {
            responseJson = Utils.failureResponseJson("该手机号码已被注册")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("用户注册失败")
        }
        
        return responseJson
    }
}

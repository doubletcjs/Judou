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
            statement = "SELECT userId FROM \(accounttable) WHERE mobile = '\(mobile)'"
        }
        
        if nickname.count > 0 {
            statement = "SELECT userId FROM \(accounttable) WHERE nickname = '\(nickname)'"
        }
        
        if userId.count > 0 {
            statement = "SELECT userId FROM \(accounttable) WHERE userId = '\(userId)'"
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
    // MARK: - 获取我的账号(登录)信息
    ///
    /// - Parameters:
    ///   - loginId: 登录用户id
    ///   - userId: 用户id
    /// - Returns: 返回JSON数据
    func getAccountHomePage(userId: String, loginId: String) -> String {
        let accountStatus = checkAccount(mobile: "", nickname: "", userId: userId)
        if accountStatus == 1 {
            var statement = ""
            var keys: [String] = [
                "\(accounttable).userId",
                "\(accounttable).nickname",
                "\(accounttable).portrait",
                "\(accounttable).gender",
                "\(accounttable).status",
                "COUNT(DISTINCT \(collecttable).objectId) collectionCount",
                "COUNT(DISTINCT \(posttable).objectId) postCount",
                "COUNT(DISTINCT attention.authorId) attentionCount",
                "COUNT(DISTINCT fan.userId) fanCount",
                "COUNT(DISTINCT \(praiseposttable).objectId) praiseCount",
                "COUNT(DISTINCT \(reportusertable).objectId) reportCount"]
            
            var originalKeys: [String] = [
                "userId",
                "nickname",
                "portrait",
                "gender",
                "status",
                "collectionCount",
                "postCount",
                "attentionCount",
                "fanCount",
                "praiseCount",
                "reportCount"]
            
            var privateConditions1 = ""
            var privateConditions2 = ""
            var countConditions: [String] = [
                "LEFT JOIN \(collecttable) ON (\(collecttable).authorId = '\(userId)')",
                "LEFT JOIN \(posttable) ON (\(posttable).authorId = '\(userId)')",
                "LEFT JOIN \(attentionfantable) attention ON (attention.authorId = '\(userId)')",
                "LEFT JOIN \(attentionfantable) fan ON (fan.userId = '\(userId)')",
                "LEFT JOIN \(praiseposttable) ON (\(praiseposttable).authorId = '\(userId)')",
                "LEFT JOIN \(reportusertable) ON (\(reportusertable).userId = '\(userId)')"]
            
            if loginId != userId {
                privateConditions1 = "AND \(collecttable).isPrivate = FALSE"
                privateConditions2 = "AND \(posttable).isPrivate = FALSE"
                
                //查看别人公开的帖子、收藏
                countConditions[0] = "LEFT JOIN \(collecttable) ON (\(collecttable).authorId = '\(userId)' \(privateConditions1))"
                countConditions[1] = "LEFT JOIN \(posttable) ON (\(posttable).authorId = '\(userId)' \(privateConditions2))"
                
                //是否关注
                keys.append("COUNT(DISTINCT \(attentionfantable).objectId) fanAttentionCount")
                originalKeys.append("fanAttentionCount")
                countConditions.append("LEFT JOIN \(attentionfantable) ON (\(attentionfantable).authorId = '\(loginId)' AND \(attentionfantable).userId = '\(userId)')")
            }
            
            if userId.count > 0 {
                statement = "SELECT \(keys.joined(separator: ", ")) FROM \(accounttable) \(countConditions.joined(separator: " ")) WHERE \(accounttable).userId = '\(userId)' GROUP BY \(accounttable).userId"
            }
            
            if statement.count == 0 {
                return Utils.failureResponseJson("获取用户信息失败，用户id为空")
            }
            
            if mysql.query(statement: statement) == false {
                Utils.logError("获取用户信息", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("获取用户信息失败")
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    var dict: [String: Any] = [:]
                    var keys: [String] = originalKeys
                    
                    results.forEachRow { (row) in
                        for idx in 0...row.count-1 {
                            let key = keys[idx]
                            dict["\(key)"] = row[idx]! as Any
                        }
                    }
                    
                    if dict["nickname"] as! String == "" {
                        dict["nickname"] = "User_\(dict["userId"] as! String)"
                    }
                    
                    if dict["fanAttentionCount"] != nil {
                        dict["isAttention"] = false
                        if Int(dict["fanAttentionCount"] as! String) != 0 {
                            dict["isAttention"] = true
                        }
                        
                        dict["fanAttentionCount"] = nil
                    }
                    
                    responseJson = Utils.successResponseJson(dict)
                } else {
                    responseJson = Utils.failureResponseJson("用户信息查询失败")
                }
            }
        } else if accountStatus == 0 {
            responseJson = Utils.failureResponseJson("用户不存在")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("获取用户信息失败")
        }
        
        return responseJson
    }
    
    func getMyAccount(mobile: String, userId: String) -> String {
        let accountStatus = checkAccount(mobile: mobile, nickname: "", userId: userId)
        if accountStatus == 1 {
            if userId.count > 0 {
                responseJson = self.getAccountHomePage(userId: userId, loginId: userId)
            } else {
                let statement = "SELECT \(accounttable).userId FROM \(accounttable) WHERE \(accounttable).mobile = '\(mobile)'"
                
                if mysql.query(statement: statement) == false {
                    Utils.logError("获取用户信息", mysql.errorMessage())
                    responseJson = Utils.failureResponseJson("获取用户信息失败")
                } else {
                    let results = mysql.storeResults()!
                    if results.numRows() > 0 {
                        var aUserId: String = ""
                        
                        results.forEachRow { (row) in
                            for idx in 0...row.count-1 {
                                aUserId = row[idx]!
                            }
                        }
                        
                        responseJson = self.getAccountHomePage(userId: aUserId, loginId: aUserId)
                    } else {
                        responseJson = Utils.failureResponseJson("用户不存在")
                    }
                }
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
            func updateInfo() -> Void {
                var contentValue: [String] = []
                params.keys.forEach { (key) in
                    if key != "userId" {
                        let value = params[key]
                        contentValue.append("\(key) = '\(value!)'")
                    }
                }
                
                let statement = "UPDATE \(accounttable) SET \(contentValue.joined(separator: ", ")) WHERE userId = '\(userId)'"
                if mysql.query(statement: statement) == false {
                    Utils.logError("更新用户信息", mysql.errorMessage())
                    responseJson = Utils.failureResponseJson("更新用户信息失败")
                } else {
                    responseJson = self.getMyAccount(mobile: "", userId: userId)
                }
            }
            
            if params["nickname"] != nil {
                let nickname: String = params["nickname"] as! String
                if checkAccount(mobile: "", nickname: nickname, userId: "") == 1 {
                    responseJson = Utils.failureResponseJson("昵称已被占用")
                } else {
                    updateInfo()
                }
            } else {
                updateInfo()
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
            let statement = "SELECT AES_DECRYPT(password, '\(AES_ENCRYPT_KEY)') FROM \(accounttable) WHERE mobile = '\(mobile)'"
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
                    let statement = "UPDATE \(accounttable) SET password = AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)') WHERE mobile = '\(mobile)'"
                    
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
            let statement = "SELECT AES_DECRYPT(password, '\(AES_ENCRYPT_KEY)') FROM \(accounttable) WHERE mobile = '\(mobile)'"
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
                    responseJson = self.getMyAccount(mobile: mobile, userId: "")
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
            let statement = "INSERT INTO \(accounttable) (mobile, password, nickname, portrait, birthday, date, level) VALUES \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("创建用户", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("用户注册失败")
            } else {
                //返回登录信息
                responseJson = self.getMyAccount(mobile: mobile, userId: "")
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
            let statement = "INSERT INTO \(accounttable) (mobile, password, nickname, portrait, birthday, date, level) VALUES \(values)"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("创建用户", mysql.errorMessage())
                responseJson = Utils.failureResponseJson("用户注册失败")
            } else {
                //返回登录信息
                responseJson = self.getMyAccount(mobile: mobile, userId: "")
            }
        } else if accountStatus == 1 {
            responseJson = Utils.failureResponseJson("该手机号码已被注册")
        } else if accountStatus == 2 {
            responseJson = Utils.failureResponseJson("用户注册失败")
        }
        
        return responseJson
    }
}

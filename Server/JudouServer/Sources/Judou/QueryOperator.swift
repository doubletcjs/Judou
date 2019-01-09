//
//  QueryOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/27.
//

import Foundation

class QueryOperator: BaseOperator {
    // MARK: - 用户模糊搜索列表
    func accountSearchListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let searchKey: String = params["searchKey"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        var keys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender",
            "\(accounttable).status"]
        
        var originalKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender",
            "status"]
        
        var statements: [String] = []
        
        if loginId.count > 0 {
            keys.append("COUNT(DISTINCT fanAttentionTable.objectId) fanAttentionCount")
            originalKeys.append("fanAttentionCount")
            statements.append("LEFT JOIN \(attentionfantable) fanAttentionTable ON (fanAttentionTable.authorId = '\(loginId)' AND fanAttentionTable.userId = \(accounttable).userId)")
        }
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(accounttable) \(statements.joined(separator: " ")) WHERE \(accounttable).nickname LIKE '%\(searchKey)%' GROUP BY \(accounttable).userId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户模糊搜索", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("搜索失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        let key = originalKeys[idx]
                        let value = row[idx]
                        dict[key] = value
                        
                        if dict["fanAttentionCount"] != nil {
                            dict["isAttention"] = false
                            if Int(dict["fanAttentionCount"] as! String) != 0 {
                                dict["isAttention"] = true
                            }
                            
                            dict["fanAttentionCount"] = nil
                        }
                    }
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 帖子模糊搜索列表
    func postSearchListQuery(params: [String: Any]) -> String {
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        let loginId: String = params["loginId"] as! String
        let searchKey: String = params["searchKey"] as! String
        
        let keys: [String] = [
            "\(posttable).objectId",
            "\(posttable).isPrivate",
            "\(posttable).postDate",
            "\(posttable).image",
            "\(posttable).content",
            "\(posttable).postType",
            "COUNT(DISTINCT praisepostcount.objectId) praiseCount",
            "COUNT(DISTINCT \(commenttable).objectId) commentCount",
            "COUNT(DISTINCT \(collectposttable).objectId) collectCount",
            "COUNT(DISTINCT praisepost.objectId) isPraiseCount",
            "COUNT(DISTINCT collectpost.objectId) isCollectCount",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait"] //基础字段
        
        let statements: [String] = [ 
            "LEFT JOIN \(praiseposttable) praisepostcount ON (praisepostcount.postId = \(posttable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(collectposttable) ON (\(collectposttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(praiseposttable) praisepost ON (praisepost.postId = \(posttable).objectId AND praisepost.authorId = '\(loginId)')",
            "LEFT JOIN \(collectposttable) collectpost ON (collectpost.postId = \(posttable).objectId AND collectpost.authorId = '\(loginId)')",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(posttable).authorId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(posttable) \(statements.joined(separator: " ")) WHERE \(posttable).content LIKE '%\(searchKey)%' GROUP BY \(posttable).objectId ORDER BY \(posttable).objectId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        let valueOfKeys: [String] = [
            "objectId",
            "isPrivate",
            "postDate",
            "image",
            "content",
            "postType",
            "praiseCount",
            "commentCount",
            "collectCount",
            "isPraiseCount",
            "isCollectCount"] //基础字段
        
        let accountValueOfKeys: [String] = [
            "userId",
            "nickname",
            "portrait"];
        
        if mysql.query(statement: statement) == false {
            Utils.logError("帖子模糊搜索", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("搜索失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    var author: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        if idx < valueOfKeys.count {
                            let key = valueOfKeys[idx]
                            let value = row[idx]
                            dict[key] = value
                            
                            if dict["isPraiseCount"] != nil {
                                dict["isPraise"] = false
                                if Int(dict["isPraiseCount"] as! String) != 0 {
                                    dict["isPraise"] = true
                                }
                                
                                dict["isPraiseCount"] = nil
                            }
                            
                            if dict["isCollectCount"] != nil {
                                dict["isCollect"] = false
                                if Int(dict["isCollectCount"] as! String) != 0 {
                                    dict["isCollect"] = true
                                }
                                
                                dict["isCollectCount"] = nil
                            }
                        } else {
                            let accountIdx: Int = idx-valueOfKeys.count
                            let key = accountValueOfKeys[accountIdx]
                            let value = row[idx]
                            author[key.replacingOccurrences(of: "\(accounttable).", with: "")] = value
                        }
                    }
                    
                    if author.count > 0 {
                        dict["author"] = author
                    }
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 喜欢的帖子列表
    func postPraiseListQuery(params: [String: Any]) -> String {
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        let userId: String = params["userId"] as! String
        
        let keys: [String] = [
            "\(posttable).objectId",
            "\(posttable).isPrivate",
            "\(posttable).postDate",
            "\(posttable).image",
            "\(posttable).content",
            "\(posttable).postType",
            "COUNT(DISTINCT praisepostcount.objectId) praiseCount",
            "COUNT(DISTINCT \(commenttable).objectId) commentCount",
            "COUNT(DISTINCT \(collectposttable).objectId) collectCount",
            "COUNT(DISTINCT praisepost.objectId) isPraiseCount",
            "COUNT(DISTINCT collectpost.objectId) isCollectCount",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait"] //基础字段
        
        let statements: [String] = [
            "LEFT JOIN \(posttable) ON (\(posttable).objectId = \(praiseposttable).postId)",
            "LEFT JOIN \(praiseposttable) praisepostcount ON (praisepostcount.postId = \(posttable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(collectposttable) ON (\(collectposttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(praiseposttable) praisepost ON (praisepost.postId = \(posttable).objectId AND praisepost.authorId = '\(userId)')",
            "LEFT JOIN \(collectposttable) collectpost ON (collectpost.postId = \(posttable).objectId AND collectpost.authorId = '\(userId)')",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(posttable).authorId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(praiseposttable) \(statements.joined(separator: " ")) WHERE \(praiseposttable).authorId = '\(userId)' GROUP BY \(posttable).objectId ORDER BY \(posttable).objectId DESC LIMIT \(currentPage*pageSize), \(pageSize)"
        
        let valueOfKeys: [String] = [
            "objectId",
            "isPrivate",
            "postDate",
            "image",
            "content",
            "postType",
            "praiseCount",
            "commentCount",
            "collectCount",
            "isPraiseCount",
            "isCollectCount"] //基础字段
        
        let accountValueOfKeys: [String] = [
            "userId",
            "nickname",
            "portrait"]; 
        
        if mysql.query(statement: statement) == false {
            Utils.logError("喜欢的帖子列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("喜欢的帖子查询失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    var author: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        if idx < valueOfKeys.count {
                            let key = valueOfKeys[idx]
                            let value = row[idx]
                            dict[key] = value
                            
                            if dict["isPraiseCount"] != nil {
                                dict["isPraise"] = false
                                if Int(dict["isPraiseCount"] as! String) != 0 {
                                    dict["isPraise"] = true
                                }
                                
                                dict["isPraiseCount"] = nil
                            }
                            
                            if dict["isCollectCount"] != nil {
                                dict["isCollect"] = false
                                if Int(dict["isCollectCount"] as! String) != 0 {
                                    dict["isCollect"] = true
                                }
                                
                                dict["isCollectCount"] = nil
                            }
                        } else {
                            let accountIdx: Int = idx-valueOfKeys.count
                            let key = accountValueOfKeys[accountIdx]
                            let value = row[idx]
                            author[key.replacingOccurrences(of: "\(accounttable).", with: "")] = value
                        }
                    }
                    
                    if author.count > 0 {
                        dict["author"] = author
                    }
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 帖子列表
    private func basePostListQuery(params: [String: Any], collectSQL: String, orderSQL: String) -> String {
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        let loginId: String = params["loginId"] as! String
        
        let keys: [String] = [
            "\(posttable).objectId",
            "\(posttable).isPrivate",
            "\(posttable).postDate",
            "\(posttable).image",
            "\(posttable).content",
            "\(posttable).postType",
            "COUNT(DISTINCT \(praiseposttable).objectId) praiseCount",
            "COUNT(DISTINCT \(commenttable).objectId) commentCount",
            "COUNT(DISTINCT \(collectposttable).objectId) collectCount",
            "COUNT(DISTINCT praisepost.objectId) isPraiseCount",
            "COUNT(DISTINCT collectpost.objectId) isCollectCount",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait"] //基础字段
        
        let statements: [String] = [
            "LEFT JOIN \(praiseposttable) ON (\(praiseposttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(collectposttable) ON (\(collectposttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(praiseposttable) praisepost ON (praisepost.postId = \(posttable).objectId AND praisepost.authorId = '\(loginId)')",
            "LEFT JOIN \(collectposttable) collectpost ON (collectpost.postId = \(posttable).objectId AND collectpost.authorId = '\(loginId)')",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(posttable).authorId)"]
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(posttable) \(statements.joined(separator: " ")) \(collectSQL) GROUP BY \(posttable).objectId \(orderSQL) LIMIT \(currentPage*pageSize), \(pageSize)"
        
        let valueOfKeys: [String] = [
            "objectId",
            "isPrivate",
            "postDate",
            "image",
            "content",
            "postType",
            "praiseCount",
            "commentCount",
            "collectCount",
            "isPraiseCount",
            "isCollectCount"] //基础字段
        
        let accountValueOfKeys: [String] = [
            "userId",
            "nickname",
            "portrait"];
        
        if mysql.query(statement: statement) == false {
            Utils.logError("我的帖子列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("我的帖子列表查询失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    var author: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        if idx < valueOfKeys.count {
                            let key = valueOfKeys[idx]
                            let value = row[idx]
                            dict[key] = value
                            
                            if dict["isPraiseCount"] != nil {
                                dict["isPraise"] = false
                                if Int(dict["isPraiseCount"] as! String) != 0 {
                                    dict["isPraise"] = true
                                }
                                
                                dict["isPraiseCount"] = nil
                            }
                            
                            if dict["isCollectCount"] != nil {
                                dict["isCollect"] = false
                                if Int(dict["isCollectCount"] as! String) != 0 {
                                    dict["isCollect"] = true
                                }
                                
                                dict["isCollectCount"] = nil
                            }
                        } else {
                            let accountIdx: Int = idx-valueOfKeys.count
                            let key = accountValueOfKeys[accountIdx]
                            let value = row[idx]
                            author[key.replacingOccurrences(of: "\(accounttable).", with: "")] = value
                        }
                    }
                    
                    if author.count > 0 {
                        dict["author"] = author
                    }
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 用户发布的帖子列表
    func myPostListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        
        var collectSQL: String = "WHERE \(posttable).authorId = '\(userId)' AND \(posttable).isPrivate = false"
        var orderSQL: String = ""
        if loginId.count > 0 && loginId == userId {
            //当前登录用户查看自己所有的帖子
            collectSQL = "WHERE \(posttable).authorId = '\(userId)'"
            orderSQL = "ORDER BY \(posttable).objectId DESC"
        }
        
        return self.basePostListQuery(params: params, collectSQL: collectSQL, orderSQL: orderSQL)
    }
    // MARK: - 广场
    func squarePostListQuery(params: [String: Any]) -> String {
        let collectSQL: String = "WHERE \(posttable).isPrivate = false"
        let orderSQL: String = "ORDER BY \(posttable).objectId DESC"
        
        return self.basePostListQuery(params: params, collectSQL: collectSQL, orderSQL: orderSQL)
    }
    // MARK: - 用户粉丝列表 A(userId) 的粉丝列表 where userId==A
    func userFanListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        var keys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender",
            "\(accounttable).status"]
        
        var originalKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender",
            "status"]
        
        var statements: [String] = []
        
        if loginId.count > 0 {
            keys.append("COUNT(DISTINCT fanAttentionTable.objectId) fanAttentionCount")
            originalKeys.append("fanAttentionCount")
            statements.append("LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(attentionfantable).authorId)")
            statements.append("LEFT JOIN \(attentionfantable) fanAttentionTable ON (fanAttentionTable.authorId = '\(loginId)' AND fanAttentionTable.userId = \(attentionfantable).authorId)")
        }
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(attentionfantable) \(statements.joined(separator: " ")) WHERE \(attentionfantable).userId = '\(userId)' GROUP BY \(attentionfantable).authorId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户粉丝列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户粉丝列表查询失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        let key = originalKeys[idx]
                        let value = row[idx]
                        dict[key] = value
                        
                        if dict["fanAttentionCount"] != nil {
                            dict["isAttention"] = false
                            if Int(dict["fanAttentionCount"] as! String) != 0 {
                                dict["isAttention"] = true
                            }
                            
                            dict["fanAttentionCount"] = nil
                        }
                    }
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
    // MARK: - 用户关注列表 A 的关注列表 where authorId==A
    func userAttentionListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        var keys: [String] = [
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait",
            "\(accounttable).gender",
            "\(accounttable).status"]
        
        var originalKeys: [String] = [
            "userId",
            "nickname",
            "portrait",
            "gender",
            "status"]
        
        var statements: [String] = []
        
        if loginId.count > 0 {
            keys.append("COUNT(DISTINCT fanAttentionTable.objectId) fanAttentionCount")
            originalKeys.append("fanAttentionCount")
            statements.append("LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(attentionfantable).userId)")
            statements.append("LEFT JOIN \(attentionfantable) fanAttentionTable ON (fanAttentionTable.authorId = '\(loginId)' AND fanAttentionTable.userId = \(attentionfantable).userId)")
        }
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(attentionfantable) \(statements.joined(separator: " ")) WHERE \(attentionfantable).authorId = '\(userId)' GROUP BY \(attentionfantable).userId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("用户关注列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("用户关注列表查询失败")
        } else {
            var postList = [[String: Any]]()
            let results = mysql.storeResults()
            if results != nil && results!.numRows() > 0 {
                results!.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        let key = originalKeys[idx]
                        let value = row[idx]
                        dict[key] = value
                        
                        if dict["fanAttentionCount"] != nil {
                            dict["isAttention"] = false
                            if Int(dict["fanAttentionCount"] as! String) != 0 {
                                dict["isAttention"] = true
                            }
                            
                            dict["fanAttentionCount"] = nil
                        }
                    }
                    
                    postList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(postList)
        }
        
        return responseJson
    }
}

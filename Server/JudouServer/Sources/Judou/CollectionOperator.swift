//
//  CollectionOperator.swift
//  Judou
//
//  Created by 4work on 2019/1/3.
//

import Foundation

class CollectionOperator: BaseOperator {
    // MARK: - 收藏夹帖子列表
    func collectionPostListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        let collectionId: String = params["collectionId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        let keys: [String] = [
            "\(posttable).objectId",
            "\(posttable).isPrivate",
            "\(posttable).postDate",
            "\(posttable).image",
            "\(posttable).content",
            "\(posttable).postType",
            "COUNT(DISTINCT \(praiseposttable).objectId) praiseCount",
            "COUNT(DISTINCT \(commenttable).objectId) commentCount",
            "COUNT(DISTINCT allcollectpost.objectId) collectCount",
            "COUNT(DISTINCT praisepost.objectId) isPraiseCount",
            "COUNT(DISTINCT collectpost.objectId) isCollectCount",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait"] //基础字段
        
        var baseJoin: String = "RIGHT JOIN \(posttable) ON (\(posttable).objectId = \(collectposttable).postId AND \(posttable).isPrivate = false)"
        if loginId.count > 0 && loginId == userId {
            baseJoin = "LEFT JOIN \(posttable) ON (\(posttable).objectId = \(collectposttable).postId)"
        }
        
        let statements: [String] = [
            baseJoin,
            "LEFT JOIN \(praiseposttable) ON (\(praiseposttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(collectposttable) allcollectpost ON (allcollectpost.postId = \(posttable).objectId)",
            "LEFT JOIN \(praiseposttable) praisepost ON (praisepost.postId = \(posttable).objectId AND praisepost.authorId = '\(loginId)')",
            "LEFT JOIN \(collectposttable) collectpost ON (collectpost.postId = \(posttable).objectId AND collectpost.authorId = '\(loginId)')",
            "LEFT JOIN \(accounttable) ON (\(accounttable).userId = \(posttable).authorId)"]
        
        let collectSQL: String = "WHERE \(collectposttable).collectId = '\(collectionId)'"
        
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(collectposttable) \(statements.joined(separator: " ")) \(collectSQL) GROUP BY \(posttable).objectId LIMIT \(currentPage*pageSize), \(pageSize)"
        
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
    // MARK: - 收藏夹列表
    func collectionListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let userId: String = params["userId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        var postId: String = ""
        if params["postId"] != nil {
            postId = params["postId"] as! String
        }
        
        var collectSQL: String = "WHERE \(collecttable).authorId = '\(userId)' AND \(collecttable).isPrivate = false"
        if loginId.count > 0 && loginId == userId {
            //当前登录用户查看自己的收藏夹
            collectSQL = "WHERE \(collecttable).authorId = '\(userId)'"
        }
        
        var statementKeys: [String] = [
            "\(collecttable).objectId",
            "\(collecttable).name",
            "\(collecttable).cover",
            "\(collecttable).isPrivate",
            "\(collecttable).authorId",
            "\(collecttable).introduction",
            "COUNT(DISTINCT \(collectposttable).objectId) postCount"]
        
        var countStatements: [String] = [
            "LEFT JOIN \(collectposttable) ON (\(collectposttable).authorId = \(userId) AND \(collectposttable).collectId = \(collecttable).objectId)"]
        
        if postId.count > 0 {
            statementKeys.append("COUNT(DISTINCT cp.objectId) isPostCollectCount")
            countStatements.append("LEFT JOIN \(collectposttable) cp ON (cp.authorId = '\(userId)' AND cp.postId = '\(postId)' AND cp.collectId = \(collecttable).objectId)")
        }
        
        let statement = "SELECT \(statementKeys.joined(separator: ", ")) FROM \(collecttable) \(countStatements.joined(separator: " ")) \(collectSQL) GROUP BY \(collecttable).objectId LIMIT \(currentPage*pageSize), \(pageSize)"
        
        var keys: [String] = [
            "objectId",
            "name",
            "cover",
            "isPrivate",
            "authorId",
            "introduction",
            "postCount"]
        
        if postId.count > 0 {
            keys.append("isPostCollectCount")
        }
        
        if mysql.query(statement: statement) == false {
            Utils.logError("收藏夹列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("收藏夹列表查询失败")
        } else {
            let results = mysql.storeResults()!
            var collectionList = [[String: Any]]()
            if results.numRows() > 0 {
                results.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        let key = keys[idx]
                        let value = row[idx]
                        dict[key] = value
                        
                        if dict["isPostCollectCount"] != nil {
                            dict["isPostCollect"] = false
                            if Int(dict["isPostCollectCount"] as! String) != 0 {
                                dict["isPostCollect"] = true
                            }
                            
                            dict["isPostCollectCount"] = nil
                        }
                    }
                    
                    collectionList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(collectionList)
        }
        
        return responseJson
    }
}

//
//  QueryOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/27.
//

import Foundation

class QueryOperator: BaseOperator {
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
            "COUNT(DISTINCT \(praisepost).objectId) praiseCount",
            "COUNT(DISTINCT \(commenttable).objectId) commentCount",
            "COUNT(DISTINCT \(collectpost).objectId) collectCount",
            "COUNT(DISTINCT praisepost.objectId) isPraiseCount",
            "COUNT(DISTINCT collectpost.objectId) isCollectCount",
            "\(accounttable).userId",
            "\(accounttable).nickname",
            "\(accounttable).portrait"] //基础字段
        
        let statements: [String] = [
            "LEFT JOIN \(praisepost) ON (\(praisepost).postId = \(posttable).objectId)",
            "LEFT JOIN \(commenttable) ON (\(commenttable).postId = \(posttable).objectId)",
            "LEFT JOIN \(collectpost) ON (\(collectpost).postId = \(posttable).objectId)",
            "LEFT JOIN \(praisepost) praisepost ON (praisepost.postId = \(posttable).objectId AND praisepost.authorId = \(loginId))",
            "LEFT JOIN \(collectpost) collectpost ON (collectpost.postId = \(posttable).objectId AND collectpost.authorId = \(loginId))",
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
}
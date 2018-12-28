//
//  QueryOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/27.
//

import Foundation

class QueryOperator: BaseOperator {
    // MARK: - 收藏夹列表
    func collectionListQuery(params: [String: Any]) -> String {
        let loginId: String = params["loginId"] as! String
        let currentPage: Int = Int(params["currentPage"] as! String)!
        let pageSize: Int = Int(params["pageSize"] as! String)!
        
        var collectSQL: String = ""
        if loginId.count > 0 {
            collectSQL = "where authorId = '\(loginId)'"
        }

        let keys: [String] = ["objectId", "name", "cover", "isPrivate", "introduction"]
        let statement = "select \(keys.joined(separator: ", ")) from \(collecttable) \(collectSQL) order by objectId asc limit \(currentPage*pageSize), \(pageSize)"
        if mysql.query(statement: statement) == false {
            Utils.logError("收藏夹列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("收藏夹列表查询失败")
        } else {
            let results = mysql.storeResults()!
            var collectionList = [[String: Any]]()
            results.forEachRow { (row) in
                var dict: [String: Any] = [:]
                for idx in 0...row.count-1 {
                    let key = keys[idx]
                    let value = row[idx]
                    dict[key] = value
                }
                
                collectionList.append(dict)
            }
            
            responseJson = Utils.successResponseJson(collectionList)
        }
        
        return responseJson
    }
    // MARK: - 标签列表
    func labelListQuery(params: [String: Any]) -> String {
        let isAdmin: Bool = Bool(params["isAdmin"] as! String)!
        
        var statusSQL: String = "status = '\(1)'"
        if isAdmin == true {
            statusSQL = "status = '\(0)' or status = '\(1)' or status = '\(3)'"
        }
        
        let keys: [String] = ["objectId", "title", "cover", "authorId", "status"]
        let statement = "select \(keys.joined(separator: ", ")) from \(labeltable) where \(statusSQL) order by objectId asc"
        if mysql.query(statement: statement) == false {
            Utils.logError("标签列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("标签列表查询失败")
        } else {
            let results = mysql.storeResults()!
            var labelList = [[String: Any]]()
            results.forEachRow { (row) in
                var dict: [String: Any] = [:]
                for idx in 0...row.count-1 {
                    let key = keys[idx]
                    let value = row[idx]
                    dict[key] = value
                }
                
                labelList.append(dict)
            }
            
            responseJson = Utils.successResponseJson(labelList)
        }
        
        return responseJson
    }
}

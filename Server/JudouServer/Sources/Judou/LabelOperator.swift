//
//  LabelOperator.swift
//  Judou
//
//  Created by 4work on 2019/1/3.
//

import Foundation

class LabelOperator: BaseOperator {
    // MARK: - 标签列表
    func labelListQuery(params: [String: Any]) -> String {
        let isAdmin: Bool = Bool(params["isAdmin"] as! String)!
        
        var statusSQL: String = "status = '\(1)' or status = '\(3)'"
        if isAdmin == true {
            statusSQL = "status = '\(0)' or status = '\(1)' or status = '\(2)' or status = '\(3)'"
        }
        
        let keys: [String] = ["objectId", "title", "cover", "authorId", "status"]
        let statement = "SELECT \(keys.joined(separator: ", ")) FROM \(labeltable) WHERE \(statusSQL) ORDER BY objectId ASC"
        if mysql.query(statement: statement) == false {
            Utils.logError("标签列表", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("标签列表查询失败")
        } else {
            let results = mysql.storeResults()!
            var labelList = [[String: Any]]()
            if results.numRows() > 0 {
                results.forEachRow { (row) in
                    var dict: [String: Any] = [:]
                    for idx in 0...row.count-1 {
                        let key = keys[idx]
                        let value = row[idx]
                        dict[key] = value
                    }
                    
                    labelList.append(dict)
                }
            }
            
            responseJson = Utils.successResponseJson(labelList)
        }
        
        return responseJson
    }
}

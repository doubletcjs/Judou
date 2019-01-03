
//
//  CreationOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/26.
//

import Foundation

class CreationOperator: BaseOperator {
    // MARK: - 创建标签、收藏夹、名人、书籍
    ///
    /// - Parameters:
    ///   - params: 参数内容 authorId、title、cover、status|authorId、name、isPrivate、introduction、cover|authorId、name、status、introduction、cove|
    ///   - function: 类型 label、collect、famous、book
    /// - Returns: 返回JSON数据
    func baseFunctionCreation(params: [String: Any], function: String) -> String {
        var keys: [String] = []
        var values: [String] = []
        params.keys.forEach { (key) in
            let value = params[key]
            keys.append("\(key)")
            values.append("'\(value!)'")
        }
        
        var tip = "标签"
        var tableName = labeltable
        if function == "collect" {
            tip = "收藏夹"
            tableName = collecttable
        } else if function == "famous" {
            tip = "名人"
            tableName = famoustable
        } else if function == "book" {
            tip = "书籍"
            tableName = booktable
        }
        
        
        let statement = "INSERT INTO \(tableName) (\(keys.joined(separator: ", "))) VALUES (\(values.joined(separator: ", ")))"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("创建\(tip)", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("创建\(tip)失败")
        } else {
            responseJson = Utils.successResponseJson("创建\(tip)成功")
        }
        
        return responseJson
    }
    // MARK: - 发帖
    ///
    /// - Parameters:
    ///   - params: 参数内容 postDate、authorId、content、labelId、image、isPrivate|postDate、authorId、content、labelId、image、isPrivate、famousId、bookId
    /// - Returns: 返回JSON数据
    func postCreation(params: [String: Any]) -> String {
        var keys: [String] = []
        var values: [String] = []
        
        var labelId: String = ""
        var famousId: String = ""
        var bookId: String = ""
        
        params.keys.forEach { (key) in
            let value = params[key]
            keys.append("\(key)")
            values.append("'\(value!)'")
            
            if key == "labelId" {
                labelId = "\(value!)"
            }
            
            if key == "famousId" {
                famousId = "\(value!)"
            }
            
            if key == "bookId" {
                bookId = "\(value!)"
            }
        }
        
        // 保存帖子
        let statement = "INSERT INTO \(posttable) (\(keys.joined(separator: ", "))) VALUES (\(values.joined(separator: ", ")))"
        
        if mysql.query(statement: statement) == false {
            Utils.logError("发帖", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("发帖失败")
        } else {
            responseJson = Utils.successResponseJson("发帖成功")
            if mysql.query(statement: "select last_insert_id()") == false {
                print("获取帖子id失败")
            } else {
                let results = mysql.storeResults()!
                var postId = ""
                results.forEachRow { (row) in
                    for idx in 0...row.count-1 {
                        postId = row[idx]!
                        break
                    }
                }
                
                if postId.count > 0 {
                    if labelId.count > 0 {
                        //帖子关联标签
                        self.postLabelContingency(postId, labelId)
                    }
                    
                    if famousId.count > 0 {
                        //帖子关联名人（作者）
                        self.postFamousContingency(postId, famousId)
                    }
                    
                    if bookId.count > 0 {
                        //帖子关联书籍（出处）
                        self.postBookContingency(postId, bookId)
                    }
                }
            }
        }
        
        return responseJson
    }
    // MARK: - 帖子关联标签
    private func postLabelContingency(_ postId: String, _ labelId: String) -> Void {
        let statement = "INSERT INTO \(labelposttable) (postId, labelId) VALUES ('\(postId)', '\(labelId)')"
        if mysql.query(statement: statement) == false {
            Utils.logError("帖子关联标签", mysql.errorMessage())
        } else {
            print("帖子关联标签成功")
        }
    }
    // MARK: - 帖子关联名人（作者）
    private func postFamousContingency(_ postId: String, _ famousId: String) -> Void {
        let statement = "INSERT INTO \(famousposttable) (postId, famousId) VALUES ('\(postId)', '\(famousId)')"
        if mysql.query(statement: statement) == false {
            Utils.logError("帖子关联名人", mysql.errorMessage())
        } else {
            print("帖子关联名人成功")
        }
    }
    // MARK: - 帖子关联书籍（出处）
    private func postBookContingency(_ postId: String, _ bookId: String) -> Void {
        let statement = "INSERT INTO \(bookposttable) (postId, bookId) VALUES ('\(postId)', '\(bookId)')"
        if mysql.query(statement: statement) == false {
            Utils.logError("帖子书籍标签", mysql.errorMessage())
        } else {
            print("帖子关联书籍成功")
        }
    }
}

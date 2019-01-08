
//
//  CreationOperator.swift
//  Judou
//
//  Created by 4work on 2018/12/26.
//

import Foundation

class CreationOperator: BaseOperator {
    // MARK: - 删除收藏夹、名人、书籍
    func creationDelete(params: [String: Any]) -> String {
        let createType: String = params["createType"] as! String
        let objectId: String = params["objectId"] as! String
        let cover: String = params["cover"] as! String
        
        var tip = "标签"
        var tableName = labeltable
        var joinTableName = labelposttable
        var joinConditions: String = ""
        if createType == "0" {
            tip = "收藏夹"
            tableName = collecttable
            joinTableName = collectposttable
            joinConditions = "(\(joinTableName).collectId = '\(objectId)')"
        } else if createType == "1" {
            tip = "名人"
            tableName = famoustable
            joinTableName = famousposttable
            joinConditions = "(\(joinTableName).famousId = '\(objectId)')"
        } else if createType == "2" {
            tip = "书籍"
            tableName = booktable
            joinTableName = bookposttable
            joinConditions = "(\(joinTableName).bookId = '\(objectId)')"
        }
        
        let statement = "DELETE \(tableName), \(joinTableName) FROM \(tableName) LEFT JOIN \(joinTableName) ON \(joinConditions) WHERE \(tableName).objectId = '\(objectId)'"
        if mysql.query(statement: statement) == false {
            Utils.logError("删除\(tip)", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("删除\(tip)失败")
        } else {
            let localPath = server.documentRoot+cover
            Utils.deleteLocalFile(localPath)
            
            responseJson = Utils.successResponseJson("删除\(tip)成功")
        }
        
        return responseJson
    }
    // MARK: - 编辑收藏夹、名人、书籍
    func creationEdit(params: [String: Any]) -> String {
        let createType: String = params["createType"] as! String
        let objectId: String = params["objectId"] as! String
        
        var contentValue: [String] = []
        params.keys.forEach { (key) in
            if key != "objectId" && key != "createType" {
                let value = params[key]
                contentValue.append("\(key) = '\(value!)'")
            }
        }
        
        var tip = "标签"
        var tableName = labeltable
        if createType == "0" {
            tip = "收藏夹"
            tableName = collecttable
        } else if createType == "1" {
            tip = "名人"
            tableName = famoustable
        } else if createType == "2" {
            tip = "书籍"
            tableName = booktable
        }
        
        
        let statement = "UPDATE \(tableName) SET \(contentValue.joined(separator: ", ")) WHERE objectId = '\(objectId)'"
        if mysql.query(statement: statement) == false {
            Utils.logError("编辑\(tip)", mysql.errorMessage())
            responseJson = Utils.failureResponseJson("编辑\(tip)失败")
        } else {
            responseJson = Utils.successResponseJson("编辑\(tip)成功")
        }
        
        return responseJson
    }
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
    // MARK: - 收藏帖子
    ///
    /// - Parameters:
    ///   - postId: 帖子id
    ///   - authorId: 收藏人
    ///   - collectId: 收藏夹id
    /// - Returns: 返回JSON数据
    func postCollectContingency(params: [String: Any]) -> String {
        let tableName = collectposttable
        let authorId: String = params["authorId"] as! String
        let postId: String = params["postId"] as! String
        
        let postIsList1: String = params["addList"] as! String
        let postIsList2: String = params["deleteList"] as! String
        
        var addList: [String] = []
        if postIsList1.count > 0 {
            addList = postIsList1.components(separatedBy: ",")
        }
        
        var deleteList: [String] = []
        if postIsList2.count > 0 {
            deleteList = postIsList2.components(separatedBy: ",")
        }
        
        func checkCollect(_ collectId: String) -> Bool {
            let statement = "SELECT objectId FROM \(tableName) WHERE \(tableName).postId = '\(postId)' AND \(tableName).authorId = '\(authorId)' AND \(tableName).collectId = '\(collectId)'"
            
            if mysql.query(statement: statement) == false {
                Utils.logError("帖子收藏查询", mysql.errorMessage())
                return false
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    return true
                } else {
                    return false
                }
            }
        }
        
        // 状态 0 查询失败 不改变状态 1 已收藏 2 未收藏
        func checkIsCollect() -> Int {
            let statement = "SELECT COUNT(DISTINCT \(tableName).objectId) collectionCount FROM \(tableName) WHERE \(tableName).postId = '\(postId)' AND \(tableName).authorId = '\(authorId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("是否收藏", mysql.errorMessage())
                return 0
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    var status: Int = 2
                    results.forEachRow { (row) in
                        for idx in 0...row.count-1 {
                            let value = row[idx]! as String
                            if Int(value)! > 0 {
                                status = 1
                            }
                        }
                    }
                    
                    return status
                } else {
                    return 0
                }
            }
        }
        
        var isRun: Bool = false
        if addList.count > 0 {
            var tempAddList: [String] = addList
            for idx in 0...addList.count-1 {
                let collectId: String = addList[idx]
                if checkCollect(collectId) == true || collectId.count == 0 {
                    tempAddList.remove(at: idx)
                }
            }
            
            addList = tempAddList
            
            if addList.count > 0 {
                isRun = true
                var values: [String] = []
                addList.forEach { (collectId) in
                    let value = "('\(postId)', '\(authorId)', '\(collectId)')"
                    values.append(value)
                }
                
                let statement = "INSERT INTO \(tableName) (postId, authorId, collectId) VALUES \(values.joined(separator: ", "))"
                if mysql.query(statement: statement) == false {
                    Utils.logError("帖子收藏", mysql.errorMessage())
                    responseJson = Utils.successResponseJson(["isSuccessful": false, "isRun": isRun])
                } else {
                    let status: Int = checkIsCollect()
                    responseJson = Utils.successResponseJson(["isSuccessful": true, "isRun": isRun, "status": status])
                }
            }
        }
        
        if deleteList.count > 0 {
            var tempDeleteList: [String] = deleteList
            for idx in 0...deleteList.count-1 {
                let collectId: String = deleteList[idx]
                if checkCollect(collectId) == false || collectId.count == 0 {
                    tempDeleteList.remove(at: idx)
                }
            }
            
            deleteList = tempDeleteList
            
            if deleteList.count > 0 {
                isRun = true
                var values: [String] = []
                deleteList.forEach { (collectId) in
                    let value = "'\(collectId)'"
                    values.append(value)
                }
                
                let statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).postId = '\(postId)' AND \(tableName).authorId = '\(authorId)' AND \(tableName).collectId in (\(values.joined(separator: ", ")))"
                if mysql.query(statement: statement) == false {
                    Utils.logError("帖子取消收藏", mysql.errorMessage())
                    responseJson = Utils.successResponseJson(["isSuccessful": false, "isRun": isRun])
                } else {
                    let status: Int = checkIsCollect()
                    responseJson = Utils.successResponseJson(["isSuccessful": true, "isRun": isRun, "status": status])
                }
            }
        }
        
        if isRun == false {
            responseJson = Utils.successResponseJson(["isSuccessful": false, "isRun": false])
        }
        
        return responseJson
    }
    // MARK: - 关注用户
    ///
    /// - Parameters:
    ///   - userId: 被关注人
    ///   - loginId: 关注人
    /// - Returns: 返回JSON数据 状态 0 查询失败 不改变状态 1 已关注 2 未关注
    func accountAttention(params: [String: Any]) -> String {
        let tableName = attentionfantable
        
        let userId: String = params["userId"] as! String
        let loginId: String = params["loginId"] as! String
        
        // 状态 0 查询失败 不改变状态 1 已关注 2 未关注
        func checkIsAttention() -> Int {
            let statement = "SELECT COUNT(DISTINCT \(tableName).objectId) attentionCount FROM \(tableName) WHERE \(tableName).authorId = '\(loginId)' AND \(tableName).userId = '\(userId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("是否关注", mysql.errorMessage())
                return 0
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    var status: Int = 2
                    results.forEachRow { (row) in
                        for idx in 0...row.count-1 {
                            let value = row[idx]! as String
                            if Int(value)! > 0 {
                                status = 1
                            }
                        }
                    }
                    
                    return status
                } else {
                    return 0
                }
            }
        }
        
        if checkIsAttention() == 1 {
            // 取消关注
            let statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).userId = '\(userId)' AND \(tableName).authorId = '\(loginId)'"
            if mysql.query(statement: statement) == false {
                Utils.logError("取消关注", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isSuccessful": false, "status": 0])
            } else {
                let status: Int = checkIsAttention()
                responseJson = Utils.successResponseJson(["isSuccessful": true, "status": status])
            }
        } else if checkIsAttention() == 2 {
            // 添加关注
            let statement = "INSERT INTO \(tableName) (authorId, userId) VALUES ('\(loginId)', '\(userId)'))"
            if mysql.query(statement: statement) == false {
                Utils.logError("添加关注", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isSuccessful": false, "status": 0])
            } else {
                let status: Int = checkIsAttention()
                responseJson = Utils.successResponseJson(["isSuccessful": true, "status": status])
            }
        } else {
            responseJson = Utils.successResponseJson(["isSuccessful": false, "status": 0])
        }
        
        return responseJson
    }
    // MARK: - 帖子、评论点赞
    ///
    /// - Parameters:
    ///   - objectId: 帖子、评论id
    ///   - authorId: 点赞人
    ///   - praiseType: 点赞类型 0 帖子 1 评论
    /// - Returns: 返回JSON数据
    func publicPraiseContingency(objectId: String, authorId: String, praiseType: Int) -> String {
        var tableName = praiseposttable
        var tip = "帖子"
        if praiseType == 1 {
            tableName = praisecommenttable
            tip = "评论"
        }
        
        func checkIsPraise() -> Bool {
            var statement = "SELECT objectId FROM \(tableName) WHERE \(tableName).postId = '\(objectId)' AND \(tableName).authorId = '\(authorId)'"
            if praiseType == 1 {
                statement = "SELECT objectId FROM \(tableName) WHERE \(tableName).commentId = '\(objectId)' AND \(tableName).authorId = '\(authorId)'"
            }
            
            if mysql.query(statement: statement) == false {
                Utils.logError("帖子点赞查询", mysql.errorMessage())
                return false
            } else {
                let results = mysql.storeResults()!
                if results.numRows() > 0 {
                    return true
                } else {
                    return false
                }
            }
        }
        
        if checkIsPraise() == true {
            var statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).postId = '\(objectId)' AND \(tableName).authorId = '\(authorId)'"
            if praiseType == 1 {
                statement = "DELETE \(tableName) FROM \(tableName) WHERE \(tableName).commentId = '\(objectId)' AND \(tableName).authorId = '\(authorId)'"
            }
            
            if mysql.query(statement: statement) == false {
                Utils.logError("\(tip)取消点赞", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isPraise": false, "isSuccessful": false])
            } else {
                responseJson = Utils.successResponseJson(["isPraise": false, "isSuccessful": true])
            }
        } else {
            var statement = "INSERT INTO \(tableName) (postId, authorId) VALUES ('\(objectId)', '\(authorId)')"
            if praiseType == 1 {
                statement = "INSERT INTO \(tableName) (commentId, authorId) VALUES ('\(objectId)', '\(authorId)')"
            }
            
            if mysql.query(statement: statement) == false {
                Utils.logError("\(tip)点赞", mysql.errorMessage())
                responseJson = Utils.successResponseJson(["isPraise": false, "isSuccessful": false])
            } else {
                responseJson = Utils.successResponseJson(["isPraise": true, "isSuccessful": true])
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

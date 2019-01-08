//
//  ApiOperation.swift
//  Judou
//
//  Created by 4work on 2018/12/19.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// localhost html
private let LocalhostHtml: String = "<html><meta charset=\"UTF-8\"><title>Api Server</title><body>接口服务器<br>V0.0.1</body></html>"

class BasicRoutes {
    var routes: Routes {
        get {
            var baseRoutes = Routes()
            
            // localhost
            
            // Configure one server which:
            //    * Serves the hello world message at <host>:<port>/
            //    * Serves static files out of the "./webroot"
            //        directory (which must be located in the current working directory).
            //    * Performs content compression on outgoing data when appropriate.
            
            baseRoutes.add(method: .get, uri: "/", handler: localhostHandler)
            baseRoutes.add(method: .get, uri: "/**", handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)
            
            // Interface version
            baseRoutes.add(method: .get, uri: "/api/v1", handler: apiVersionHandle)
            
            // 开放注册管理员
            baseRoutes.add(method: .post, uri: "/adminAvailable", handler: adminAvailableHandle)
            
            // 注册
            baseRoutes.add(method: .post, uri: "/register", handler: registerHandle)
            
            // 管理员注册
            baseRoutes.add(method: .post, uri: "/registerAdmin", handler: registerAdminHandle)
            
            // 用户信息
            baseRoutes.add(method: .post, uri: "/accountInfo", handler: accountInfoHandle)
            
            // 修改密码
            baseRoutes.add(method: .post, uri: "/resetPasswd", handler: resetPasswordHandle)
            
            // 手机号密码登录
            baseRoutes.add(method: .post, uri: "/login", handler: passwordLoginHandle)
            
            // 更新用户信息
            baseRoutes.add(method: .post, uri: "/updateAccount", handler: updateAccountHandle)
            
            // 文件上传
            baseRoutes.add(method: .post, uri: "/fileUpload", handler: baseFileUploadHandle)
            
            // 创建标签、收藏夹、名人、书籍
            baseRoutes.add(method: .post, uri: "/functionCreation", handler: functionCreationHandle)
            
            // 编辑收藏夹、名人、书籍
            baseRoutes.add(method: .post, uri: "/creationEdit", handler: creationEditHandle)
            
            // 删除收藏夹、名人、书籍
            baseRoutes.add(method: .post, uri: "/creationDelete", handler: creationDeleteHandle)
            
            // 发帖
            baseRoutes.add(method: .post, uri: "/postCreation", handler: postCreationHandle)
            
            // 标签列表
            baseRoutes.add(method: .post, uri: "/labelList", handler: labelListHandle)
            
            // 收藏夹列表
            baseRoutes.add(method: .post, uri: "/collectionList", handler: collectionListHandle)
            
            // 收藏夹帖子列表
            baseRoutes.add(method: .post, uri: "/collectionPostList", handler: collectionPostListHandle)
            
            // 用户帖子列表
            baseRoutes.add(method: .post, uri: "/postList", handler: postListHandle)
            
            // 喜欢的帖子列表
            baseRoutes.add(method: .post, uri: "/postPraiseList", handler: postPraiseListHandle)
            
            // 主页用户信息
            baseRoutes.add(method: .post, uri: "/myHomePage", handler: myHomePageHandle)
            
            // 帖子、评论点赞
            baseRoutes.add(method: .post, uri: "/publicPraise", handler: publicPraiseHandle)
            
            // 收藏帖子
            baseRoutes.add(method: .post, uri: "/postCollect", handler: postCollectHandle)
            
            // 粉丝
            baseRoutes.add(method: .post, uri: "/userFanList", handler: userFanListHandle)
            
            // 关注
            baseRoutes.add(method: .post, uri: "/userAttentionList", handler: userAttentionListHandle)
            
            // 关注用户
            baseRoutes.add(method: .post, uri: "/accountAttention", handler: accountAttentionHandle)
            
            // 广场
            baseRoutes.add(method: .post, uri: "/squarePostList", handler: squarePostListHandle)
            
            // 搜索帖子
            baseRoutes.add(method: .post, uri: "/postSearchList", handler: postSearchListHandle)
            
            print("接口版本: v0.0.1")
            
            return baseRoutes
        }
    }
    // MARK: - localhost
    private func localhostHandler(request: HTTPRequest, response: HTTPResponse) {
        // Respond with a simple message.
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: LocalhostHtml)
        // Ensure that response.completed() is called when your processing is done.
        response.completed()
    }
    // MARK: - Interface version
    private func apiVersionHandle(request: HTTPRequest, response: HTTPResponse) {
        let dict: [String: Any] = ["status": "1", "version": "0.0.1"]
        
        guard dict.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("接口版本读取失败"))
            response.completed()
            
            return
        }
        
        response.appendBody(string: Utils.successResponseJson(dict))
        response.completed()
    }
    // MARK: - 开放注册管理员
    private func adminAvailableHandle(request: HTTPRequest, response: HTTPResponse) {
        let dict: [String: Any] = ["status": "1"]
        
        response.appendBody(string: Utils.successResponseJson(dict))
        response.completed()
    }
    // MARK: - 注册
    private func registerHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().registerAccount(mobile: mobile, password: password)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    
    private func registerAdminHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().registerAdminAccount(mobile: mobile, password: password)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 更新用户信息
    private func updateAccountHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count > 0 || dict["userId"] != nil else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().updateAccount(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 主页用户信息
    private func myHomePageHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        var loginId: String = ""
        
        if request.param(name: "loginId") != nil {
            loginId = request.param(name: "loginId")!
        }
        
        guard userId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().getAccountHomePage(userId: userId, loginId: loginId)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 获取我的账号(登录)信息
    private func accountInfoHandle(request: HTTPRequest, response: HTTPResponse) {
        var userId: String = ""
        
        if request.param(name: "userId") != nil {
            userId = request.param(name: "userId")!
        }
        
        guard userId.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().getMyAccount(mobile: "", userId: userId)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 修改密码
    private func resetPasswordHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().resetPassword(mobile: mobile, password: password)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 手机号密码登录
    private func passwordLoginHandle(request: HTTPRequest, response: HTTPResponse) {
        var mobile: String = ""
        var password: String = ""
        
        if request.param(name: "mobile") != nil {
            mobile = request.param(name: "mobile")!
        }
        
        if request.param(name: "password") != nil {
            password = request.param(name: "password")!
        }
        
        guard mobile.count > 0 && password.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = AccountOperator().passwordLogin(mobile: mobile, password: password)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 标签列表
    private func labelListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 1 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = LabelOperator().labelListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 收藏夹列表
    private func collectionListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count >= 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CollectionOperator().collectionListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 用户粉丝列表
    private func userFanListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().userFanListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 关注用户
    private func accountAttentionHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 2 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().accountAttention(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 用户关注列表
    private func userAttentionListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().userAttentionListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 收藏夹帖子列表
    private func collectionPostListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 5 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CollectionOperator().collectionPostListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 喜欢的帖子列表
    private func postPraiseListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 3 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().postPraiseListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 用户帖子列表
    private func postListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().myPostListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 搜索帖子
    private func postSearchListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 4 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().postSearchListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 广场
    private func squarePostListHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 3 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().squarePostListQuery(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 收藏帖子
    private func postCollectHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count >= 2 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().postCollectContingency(params: dict)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 帖子、评论点赞
    private func publicPraiseHandle(request: HTTPRequest, response: HTTPResponse) {
        var objectId: String = ""
        var authorId: String = ""
        var praiseType: Int = -1
        
        if request.param(name: "objectId") != nil {
            objectId = request.param(name: "objectId")!
        }
        
        if request.param(name: "authorId") != nil {
            authorId = request.param(name: "authorId")!
        }
        
        if request.param(name: "praiseType") != nil {
            praiseType = Int(request.param(name: "praiseType")!) ?? -1
        }
        
        guard objectId.count > 0 && authorId.count > 0 && praiseType > -1 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().publicPraiseContingency(objectId: objectId, authorId: authorId, praiseType: praiseType)
        
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 发帖
    private func postCreationHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().postCreation(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 删除收藏夹、名人、书籍
    private func creationDeleteHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count == 3 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().creationDelete(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 编辑收藏夹、名人、书籍
    private func creationEditHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            dict[param.0] = param.1
        }
        
        guard dict.keys.count > 1 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().creationEdit(params: dict)
        response.appendBody(string: requestJson)
        response.completed()
    }
    // MARK: - 创建标签、收藏夹、名人、书籍 function: label、collect、famous、book
    private func functionCreationHandle(request: HTTPRequest, response: HTTPResponse) {
        var function: String = ""
        if request.param(name: "function") != nil {
            function = request.param(name: "function")!
        }
        
        guard function.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let params = request.params()
        var dict: [String: Any] = [:]
        
        for idx in 0...params.count-1 {
            let param: (String, String) = params[idx]
            if param.0 != "function" {
                dict[param.0] = param.1
            }
        }
        
        var maxCount: Int = 4
        if function != "label" {
            maxCount = 5
        }
        
        guard dict.keys.count == maxCount else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = CreationOperator().baseFunctionCreation(params: dict, function: function)
        response.appendBody(string: requestJson)
        response.completed()
        
    }
    // MARK: - 文件上传基础方法 function: portrait collect label famous book post
    private func baseFileUploadHandle(_ request: HTTPRequest, _ response: HTTPResponse) {
        do {
            var function: String = ""
            if request.param(name: "function") != nil {
                function = request.param(name: "function")!
            }
            
            guard function.count > 0 else {
                response.setBody(string: Utils.failureResponseJson("上传参数错误"))
                response.completed()
                
                return
            }
            
            guard let uploads = request.postFileUploads, uploads.count > 0 else {
                try response.setBody(json: Utils.failureResponseJson("上传参数错误"))
                response.completed()
                return
            }
            
            //设置、创建文件存储目录
            var fileDir = Dir(server.documentRoot + "/files" + "/\(function)")
            if function == "portrait" {
                var userId: String = ""
                
                if request.param(name: "userId") != nil {
                    userId = request.param(name: "userId")!
                }
                
                guard userId.count > 0 else {
                    response.setBody(string: Utils.failureResponseJson("上传参数错误"))
                    response.completed()
                    
                    return
                }
                
                fileDir = Dir(server.documentRoot + "/files" + "/\(function)" + "/\(userId)")
            }
            
            do {
                try fileDir.create()
            } catch {
                print("\(error)")
                try response.setBody(json: Utils.failureResponseJson("无法创建功能类文件夹"))
                response.completed()
                return
            }
            
            if let uploads = request.postFileUploads, uploads.count > 0 {
                var pathArray = [String]()
                for upload in uploads {
                    //文件信息
                    /*
                    var array = [[String: Any]]()
                    array.append([
                        "fieldName": upload.fieldName,
                        "contentType": upload.contentType,
                        "fileName": upload.fileName,
                        "fileSize": upload.fileSize,
                        "tmpFileName": upload.tmpFileName
                        ])
                    */
                    // move file to webroot
                    let thisFile = File(upload.tmpFileName)
                    if (thisFile.path != "") {
                        do {
                            // 本地存放路径（本地即为Mac环境运行）
                            let resultPath = fileDir.path + upload.fileName
                            let _ = try thisFile.moveTo(path: resultPath, overWrite: true)
                            
                            // 服务器绝对路径
                            let absolutePath = resultPath.replacingOccurrences(of: server.documentRoot, with: "")
                            pathArray.append(absolutePath)
                        } catch {
                            response.setBody(string: Utils.failureResponseJson("\(error)"))
                            response.completed()
                        }
                    }
                }
                
                do {
                    try response.setBody(json: Utils.successResponseJson(pathArray))
                    response.completed()
                } catch {
                    response.setBody(string: Utils.failureResponseJson("上传参数错误"))
                    response.completed()
                }
                
            }
        } catch {
            response.setBody(string: Utils.failureResponseJson("\(error)"))
            response.completed()
        }
    } 
}

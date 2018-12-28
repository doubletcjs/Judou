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
            baseRoutes.add(method: .get, uri: "/adminAvailable", handler: adminAvailableHandle)
            
            // 注册
            baseRoutes.add(method: .post, uri: "/register", handler: registerHandle)
            
            // 管理员注册
            baseRoutes.add(method: .post, uri: "/registerAdmin", handler: registerAdminHandle)
            
            // 用户信息
            baseRoutes.add(method: .get, uri: "/accountInfo", handler: accountInfoHandle)
            
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
            
            // 发帖
            baseRoutes.add(method: .post, uri: "/postCreation", handler: postCreationHandle)
            
            // 标签列表
            baseRoutes.add(method: .get, uri: "/labelList", handler: labelListHandle)
            
            // 收藏夹列表
            baseRoutes.add(method: .get, uri: "/collectionList", handler: collectionListHandle)
            
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
    // MARK: - 用户信息
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
        
        let requestJson = AccountOperator().getAccount(mobile: "", userId: userId)
        
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
        
        let requestJson = QueryOperator().labelListQuery(params: dict)
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
        
        guard dict.keys.count == 3 else {
            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
            response.completed()
            
            return
        }
        
        let requestJson = QueryOperator().collectionListQuery(params: dict)
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
                            
                            let urlPath = resultPath.replacingOccurrences(of: server.documentRoot, with: "http://\(server.serverAddress):\(server.serverPort)")
                            pathArray.append(urlPath)
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

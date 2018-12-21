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
            
            // 注册
            baseRoutes.add(method: .post, uri: "/register", handler: registerHandle)
            
            // 用户信息
            baseRoutes.add(method: .get, uri: "/accountInfo", handler: accountInfoHandle)
            
            // 修改密码
            baseRoutes.add(method: .post, uri: "/resetPasswd", handler: resetPasswordHandle)
            
            // 手机号密码登录
            baseRoutes.add(method: .post, uri: "/login", handler: passwordLoginHandle)
            
            // 更新用户信息
            baseRoutes.add(method: .post, uri: "/updateAccount", handler: updateAccountHandle)
            
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
        let dict: [String: Any] = ["status": 1, "version": "0.0.1"]
        
        guard dict.count > 0 else {
            response.setBody(string: Utils.failureResponseJson("接口版本读取失败"))
            response.completed()
            
            return
        }
        
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
    // MARK: - 更新用户信息
    private func updateAccountHandle(request: HTTPRequest, response: HTTPResponse) {
        let params = request.params()
        var dict: [String: String] = [:]
        
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
        
//        var userId: String = ""
//        var contentJson: String = ""
//
//        if request.param(name: "userId") != nil {
//            userId = request.param(name: "userId")!
//        }
//
//        guard userId.count > 0 else {
//            response.setBody(string: Utils.failureResponseJson("请求参数错误"))
//            response.completed()
//
//            return
//        }
//
//        if request.param(name: "contentJson") != nil {
//            contentJson = request.param(name: "contentJson")!
//        }
//
//        let dict: Dictionary? = Utils.jsonToDictionary(contentJson)
//        guard dict != nil && dict!.keys.count > 0 else {
//            response.setBody(string: Utils.failureResponseJson("无法解析json串"))
//            response.completed()
//
//            return
//        }
//
//        let requestJson = AccountOperator().updateAccount(userId: userId, contentJson: contentJson)
//
//        response.appendBody(string: requestJson)
//        response.completed()
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
    func resetPasswordHandle(request: HTTPRequest, response: HTTPResponse) {
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
    func passwordLoginHandle(request: HTTPRequest, response: HTTPResponse) {
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
}

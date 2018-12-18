//
//  main.swift
//  Judou
//
//  Created by 4work on 2018/12/18.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger

// 指定服务器名
let kServerName: String! = "Judou"

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><meta charset=\"UTF-8\"><title>\(kServerName!)接口服务器</title><body>句读接口服务器<br>V0.0.1</body></html>")
	// Ensure that response.completed() is called when your processing is done.
	response.completed()
}

// Configure one server which:
//	* Serves the hello world message at <host>:<port>/
//	* Serves static files out of the "./webroot"
//		directory (which must be located in the current working directory).
//	* Performs content compression on outgoing data when appropriate.

//MARK: - 创建日志文件夹、指定存储路径
let logPath = "./files/log"
let logDir = Dir(logPath)
if !logDir.exists {
    try Dir(logPath).create()
}

LogFile.location = "\(logPath)/Server.log"

// MARK: - 配置路由
var routes = Routes()
routes.add(method: .get, uri: "/", handler: handler)
routes.add(method: .get, uri: "/**",
		   handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)

// MARK: - 服务器配置
let server = HTTPServer()
server.addRoutes(routes)
server.serverPort = 8181
server.serverName = "localhost"
server.setResponseFilters([
    (try PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

// MARK: - 启动服务器
do {
    LogFile.info("服务器启动成功")
    try server.start()
} catch let error {
    LogFile.error("服务器启动失败：\(error)")
    print("服务器启动失败：\(error)")
} 


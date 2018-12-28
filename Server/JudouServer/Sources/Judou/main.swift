//
//  main.swift
//  Judou
//
//  Created by 4work on 2018/12/18.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//
//===-----------------------------------------------------var--------------===//
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

//MARK: - Log location
private let logPath = "./files/log"
private let logDir = Dir(logPath)
if !logDir.exists {
    try Dir(logPath).create()
}

LogFile.location = "\(logPath)/Server.log"

// MARK: - Configure routes
private var routes = BasicRoutes().routes

// MARK: - Configure server
let server = HTTPServer()
server.addRoutes(routes)
server.serverPort = kServerPort
server.serverName = kServerName
server.documentRoot = kServerDocumentRoot
server.setResponseFilters([
    (try PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

// MARK: - Start server
do {
    LogFile.info("Server Start Successful")
    try server.start()
} catch let error {
    LogFile.error("Failure Start Server：\(error)") 
}

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
            
            return baseRoutes
        }
    }
    // MARK: - localhost
    func localhostHandler(request: HTTPRequest, response: HTTPResponse) {
        // Respond with a simple message.
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: "<html><meta charset=\"UTF-8\"><title>\(kServerName)Api Server</title><body>句读接口服务器<br>V0.0.1</body></html>")
        // Ensure that response.completed() is called when your processing is done.
        response.completed()
    }
    // MARK: - Interface version
    func apiVersionHandle(request: HTTPRequest, response: HTTPResponse) {
        let successArray: [String: Any] = ["status": 1, "version": "0.0.1"]
        let jsonStr = try! successArray.jsonEncodedString()
        
        response.appendBody(string: jsonStr)
        response.completed()
    }
}

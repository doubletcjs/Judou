- brew install mysql@5.7 && brew link mysql@5.7 --force
- Package.swift
```
import PackageDescription

// ServerName
let kServerName: String = "Judou"

let package = Package(
	name: kServerName,
	products: [
		.executable(name: kServerName, targets: [kServerName])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", from: "3.0.0"),
	],
	targets: [
		.target(name: kServerName, dependencies: ["PerfectHTTPServer", "PerfectMySQL", "PerfectLogger"])
	]
)
```
- ‎⁨⁨Sources⁩/⁨Judou⁩/main.swift

```
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger

// ServerName
let kServerName: String = "Judou"

//MARK: - Log location
let logPath = "./files/log"
let logDir = Dir(logPath)
if !logDir.exists {
    try Dir(logPath).create()
}

LogFile.location = "\(logPath)/Server.log"

// MARK: - Configure routes
var routes = BasicRoutes().routes

// MARK: - Configure server
let server = HTTPServer()
server.addRoutes(routes)
server.serverPort = 8181
server.serverName = "localhost"
server.setResponseFilters([
    (try PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

// MARK: - Start server
do {
    LogFile.info("Server Start Successful")
    try server.start()
} catch let error {
    LogFile.error("Failure Start Server：\(error)")
    print("Failure Start Server：\(error)")
}
```
- ApiOperation.swift

```
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
```

- swift build
- swift package generate-xcodeproj
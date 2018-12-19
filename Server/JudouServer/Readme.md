- brew install mysql@5.7 && brew link mysql@5.7 --force
- Package.swift
```
import PackageDescription

// ProjectName
private let kProjectName: String = "Judou"

let package = Package(
	name: kProjectName,
	products: [
		.executable(name: kProjectName, targets: [kProjectName])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", from: "3.0.0"),
	],
	targets: [
		.target(name: kProjectName, dependencies: ["PerfectHTTPServer", "PerfectMySQL", "PerfectLogger"])
	]
)
```
- ‎⁨⁨Sources⁩/⁨Judou⁩/main.swift

```
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger 

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
        let successArray: [String: Any] = ["status": 1, "version": "0.0.1"]
        let jsonStr = try! successArray.jsonEncodedString()
        
        response.appendBody(string: jsonStr)
        response.completed()
    }
}
```

- swift build
- swift package generate-xcodeproj
- 用户表

```
CREATE TABLE `account_table` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nickname` varchar(20) NOT NULL DEFAULT '',
  `portrait` varchar(255) DEFAULT '',
  `gender` int(1) NOT NULL DEFAULT '0',
  `birthday` date NOT NULL,
  `mobile` varchar(20) NOT NULL DEFAULT '',
  `date` datetime NOT NULL,
  `status` int(1) NOT NULL DEFAULT '0',
  `report` int(10) NOT NULL DEFAULT '0',
  `password` varchar(128) CHARACTER SET latin1 NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;
```
- 标签表

```
CREATE TABLE `label_table` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `objectId` varchar(50) NOT NULL DEFAULT '',
  `title` varchar(20) NOT NULL DEFAULT '',
  `cover` varchar(255) DEFAULT '',
  `author` int(11) unsigned NOT NULL,
  `status` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `LABELAUTHOR` (`author`),
  CONSTRAINT `LABELAUTHOR` FOREIGN KEY (`author`) REFERENCES `account_table` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;
```
- brew install mysql@5.7 && brew link mysql@5.7 --force
- Package.swift
```
import PackageDescription

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
```

- swift build
- swift package generate-xcodeproj
// swift-tools-version:4.0

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



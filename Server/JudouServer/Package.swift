// swift-tools-version:4.0

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

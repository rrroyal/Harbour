// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "KeychainKit",
	platforms: [
		.iOS(.v16),
		.macOS(.v13)
	],
	products: [
		.library(name: "KeychainKit", targets: ["KeychainKit"])
	],
	targets: [
		.target(name: "KeychainKit", dependencies: [])
	]
)

// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AppNotifications",
	platforms: [
		.iOS(.v15),
		.macOS(.v12)
	],
	products: [
		.library(name: "AppNotifications", targets: ["AppNotifications"])
	],
	dependencies: [],
	targets: [
		.target(name: "AppNotifications", dependencies: [])
	]
)

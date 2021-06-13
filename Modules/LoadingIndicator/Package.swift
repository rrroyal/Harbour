// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "LoadingIndicator",
	platforms: [
		.iOS(.v14)
	],
	products: [
		.library(name: "LoadingIndicator", targets: ["LoadingIndicator"])
	],
	dependencies: [],
	targets: [
		.target(name: "LoadingIndicator", dependencies: [])
	]
)

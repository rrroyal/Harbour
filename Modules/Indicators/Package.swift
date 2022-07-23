// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Indicators",
	platforms: [
		.iOS(.v16)
	],
	products: [
		.library(name: "Indicators", targets: ["Indicators"])
	],
	dependencies: [],
	targets: [
		.target(name: "Indicators", dependencies: [])
	]
)

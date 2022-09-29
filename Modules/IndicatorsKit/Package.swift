// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "IndicatorsKit",
	platforms: [
		.iOS(.v16)
	],
	products: [
		.library(name: "IndicatorsKit", targets: ["IndicatorsKit"])
	],
	dependencies: [],
	targets: [
		.target(name: "IndicatorsKit", dependencies: [])
	]
)

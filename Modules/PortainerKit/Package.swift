// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "PortainerKit",
	/* platforms: [
		.iOS(.v15),
		.macOS(.v12)
	], */
	products: [
		.library(name: "PortainerKit", targets: ["PortainerKit"])
	],
	dependencies: [],
	targets: [
		.target(name: "PortainerKit", dependencies: [])
	],
	swiftLanguageVersions: [.v5]
)

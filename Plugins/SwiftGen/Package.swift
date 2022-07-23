// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftGen",
	products: [
		.plugin(name: "SwiftGen", targets: ["SwiftGen"])
	],
	dependencies: [],
	targets: [
		.plugin(
			name: "SwiftGen",
			capability: .buildTool(),
			dependencies: ["swiftgen"]),
		.binaryTarget(
			name: "swiftgen",
			url: "https://github.com/nicorichard/SwiftGen/releases/download/6.5.1/swiftgen.artifactbundle.zip",
			checksum: "a8e445b41ac0fd81459e07657ee19445ff6cbeef64eb0b3df51637b85f925da8")
	]
)

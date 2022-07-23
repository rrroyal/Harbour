// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftLint",
	products: [
		.plugin(name: "SwiftLint", targets: ["SwiftLint"]),
		.plugin(name: "SwiftlintFix", targets: ["Fix with SwiftLint"])
	],
	dependencies: [],
	targets: [
		.plugin(
			name: "SwiftLint",
			capability: .buildTool(),
			dependencies: ["SwiftLintBinary"]),
		.plugin(
			name: "Fix with SwiftLint",
			capability: .command(intent: .sourceCodeFormatting(),
								 permissions: [.writeToPackageDirectory(reason: "Allows plugin to fix issues in files.")]),
			dependencies: ["SwiftLintBinary"],
			path: "Plugins/SwiftLintFix"),
		.binaryTarget(
			name: "SwiftLintBinary",
			url: "https://github.com/realm/SwiftLint/releases/download/0.47.1/SwiftLintBinary-macos.artifactbundle.zip",
			checksum: "82ef90b7d76b02e41edd73423687d9cedf0bb9849dcbedad8df3a461e5a7b555")
	]
)

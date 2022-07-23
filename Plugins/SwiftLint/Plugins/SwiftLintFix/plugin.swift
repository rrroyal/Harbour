import Foundation
import PackagePlugin
import XcodeProjectPlugin

@main
@available(macOS 13.0, *)
struct SwiftLintFixPlugin: CommandPlugin, XcodeCommandPlugin {

	func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
		let projectPath = context.package.directory
		let toolPath = try context.tool(named: "swiftlint").path
		let process = Process()
		process.executableURL = URL(filePath: toolPath.string)
		process.arguments = [
			"lint",
			"--format",
			"--fix",
			"--in-process-sourcekit",
			"--path", projectPath.string,
			"--config", "\(projectPath)/.swiftlint.yml"
		]
		try process.run()
		process.waitUntilExit()
	}

	func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
		let projectPath = context.xcodeProject.directory
		let toolPath = try context.tool(named: "swiftlint").path
		let process = Process()
		process.executableURL = URL(filePath: toolPath.string)
		process.arguments = [
			"lint",
			"--format",
			"--fix",
			"--in-process-sourcekit",
			"--path", projectPath.string,
			"--config", "\(projectPath)/.swiftlint.yml"
		]
		try process.run()
		process.waitUntilExit()
	}
}

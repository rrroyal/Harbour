import Foundation
import PackagePlugin
import XcodeProjectPlugin

@main
@available(macOS 13.0, *)
struct SwiftLintPlugin: BuildToolPlugin, XcodeBuildToolPlugin {

	func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
		let command = PackagePlugin.Command.buildCommand(
			displayName: "Running SwiftLint for \(target.name)",
			executable: try context.tool(named: "swiftlint").path,
			arguments: [
				"lint",
				"--in-process-sourcekit",
				"--path",
				target.directory.string,
				"--config",
				"\(context.package.directory.string)/.swiftlint.yml"
			],
			environment: [:]
		)
		return [command]
	}

	func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
		let projectPath = context.xcodeProject.directory
		let command = PackagePlugin.Command.buildCommand(
			displayName: "Running SwiftLint for \(target.displayName)",
			executable: try context.tool(named: "swiftlint").path,
			arguments: [
				"lint",
				"--in-process-sourcekit",
				"--path",
				projectPath,
				"--config",
				"\(projectPath)/.swiftlint.yml"
			],
			environment: [:]
		)
		return [command]
	}
}

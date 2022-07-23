import Foundation
import PackagePlugin
import XcodeProjectPlugin

@main
@available(macOS 13.0, *)
struct SwiftGenPlugin: BuildToolPlugin, XcodeBuildToolPlugin {
	private static let swiftGenConfigFilename = "swiftgen.yml"

	// We're not using PackagePlugins
	func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
		return []
	}

	func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
		let fileManager = FileManager.default

		let path = context.xcodeProject.directory.appending(Self.swiftGenConfigFilename)
		guard fileManager.fileExists(atPath: path.string) else {
			// swiftlint:disable:next line_length
			Diagnostics.remark("No SwiftGen configurations found for target \(target.displayName). If you would like to generate sources for this target include a `swiftgen.yml` in the project's root directory.")
			return []
		}

		let targetName = target.product?.name ?? target.displayName
		let outputFilesDirectory = context.xcodeProject.directory.appending([targetName, "Localization"])
		try? fileManager.removeItem(atPath: outputFilesDirectory.string)
		try? fileManager.createDirectory(atPath: outputFilesDirectory.string, withIntermediateDirectories: false)

		let executable = try context.tool(named: "swiftgen")
		let command = Command.prebuildCommand(
			displayName: "Run SwiftGen",
			executable: executable.path,
			arguments: [
				"config",
				"run",
				"--verbose",
				"--config", path
			],
			environment: [
				"PROJECT_DIR": context.xcodeProject.directory.appending(targetName),
				"TARGET_NAME": target.displayName,
				"OUTPUT_DIR": outputFilesDirectory
			],
			outputFilesDirectory: outputFilesDirectory
		)
		return [command]
	}
}

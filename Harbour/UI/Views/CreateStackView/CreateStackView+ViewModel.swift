//
//  CreateStackView+ViewModel.swift
//  Harbour
//
//  Created by royal on 14/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit
import UniformTypeIdentifiers

// MARK: - CreateStackView+ViewModel

extension CreateStackView {
	@Observable
	final class ViewModel {
		private(set) var createStackTask: Task<Stack, Swift.Error>?

		var isFileImporterPresented = false

		var isStackFileContentsTargeted = false
		var isEnvironmentEntrySheetPresented = false
		var editedEnvironmentEntry: KeyValueEntry?

		var showWholeStackFileContents = false

		var stackName = ""
		var stackFileContent: String?
		var stackEnvironment: [KeyValueEntry] = []

		var canCreateStack: Bool {
			guard
				!stackName.isReallyEmpty,
				!(stackFileContent?.isReallyEmpty ?? true)
			else { return false }
			return true
		}

		var isLoading: Bool {
			!(createStackTask?.isCancelled ?? true)
		}

		func createStack() -> Task<Stack, Swift.Error> {
			createStackTask?.cancel()
			let task = Task<Stack, Swift.Error> {
				defer { createStackTask?.cancel() }

				let stackSettings = try stackDeploymentSettings()
				let createdStack = try await PortainerStore.shared.createStack(stackSettings: stackSettings)
				return createdStack
			}
			self.createStackTask = task
			return task
		}

		func loadStackFile(at url: URL) throws -> String {
			guard url.startAccessingSecurityScopedResource() else {
				throw Error.unableToAccessFile
			}

			let data = try Data(contentsOf: url)
			url.stopAccessingSecurityScopedResource()

			guard let string = String(data: data, encoding: .utf8) else {
				throw Error.unableToReadFile
			}

			self.stackFileContent = string
			return string
		}

		func handleStackFileDrop(item: NSItemProvider) async throws -> String? {
			guard let url = try await item.loadItem(forTypeIdentifier: UTType.yaml.identifier) as? URL else { return nil }
			return try loadStackFile(at: url)
		}

		func editEnvironmentEntry(old oldEntry: KeyValueEntry?, new newEntry: KeyValueEntry?) {
			if let oldEntry, let newEntry {
				if let oldIndex = stackEnvironment.firstIndex(of: oldEntry) {
					stackEnvironment[oldIndex] = newEntry
				} else {
					stackEnvironment.append(newEntry)
				}
			} else if let oldEntry, newEntry == nil {
				if let oldIndex = stackEnvironment.firstIndex(of: oldEntry) {
					stackEnvironment.remove(at: oldIndex)
				}
			} else if oldEntry == nil, let newEntry {
				stackEnvironment.append(newEntry)
			}
		}
	}
}

// MARK: - CreateStackView.ViewModel+Private

private extension CreateStackView.ViewModel {
	func stackDeploymentSettings() throws -> some StackDeploymentSettings {
		guard let stackFileContent else {
			throw Error.invalidDeploymentSettings
		}

		return StackDeployment.DeploymentSettings.StandaloneString(
			env: stackEnvironment.map { .init(name: $0.key, value: $0.value) },
			fromAppTemplate: nil,
			name: stackName,
			stackFileContent: stackFileContent
		)
	}
}

// MARK: - CreateStackView.ViewModel+Error

extension CreateStackView.ViewModel {
	enum Error: LocalizedError {
		case unableToAccessFile
		case unableToReadFile

		case invalidDeploymentSettings

		var errorDescription: String? {
			switch self {
			case .unableToAccessFile:
				String(localized: "CreateStackView.ViewModel.Error.UnableToAccessFile")
			case .unableToReadFile:
				String(localized: "CreateStackView.ViewModel.Error.UnableToReadFile")
			case .invalidDeploymentSettings:
				String(localized: "CreateStackView.ViewModel.Error.InvalidDeploymentSettings")
			}
		}
	}
}

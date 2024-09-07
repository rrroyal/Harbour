//
//  CreateStackView+ViewModel.swift
//  Harbour
//
//  Created by royal on 14/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import OSLog
import PortainerKit
import UniformTypeIdentifiers

// MARK: - CreateStackView+ViewModel

extension CreateStackView {
	@Observable @MainActor
	final class ViewModel {
		private(set) var createStackTask: Task<Stack, Swift.Error>?
		private(set) var createStackError: Swift.Error?

		private(set) var fetchStackFileTask: Task<Void, Swift.Error>?
		private(set) var fetchStackFileError: Swift.Error?

		let logger = Logger(.view(CreateStackView.self))

		var isFileImportSheetPresented = false
		var isTextEditorSheetPresented = false

		var isStackFileContentTargeted = false
		var isEnvironmentEntrySheetPresented = false
		var editedEnvironmentEntry: KeyValueEntry?

		var stackID: Stack.ID?
		var stackName = ""
		var stackFileContent: String?
		var stackEnvironment: [KeyValueEntry] = []

		var shouldCreateNewStack: Bool {
			stackID == nil
		}

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

		var isFetchingStackFile: Bool {
			!(fetchStackFileTask?.isCancelled ?? true)
		}

		func createOrUpdateStack(pullImage: Bool) -> Task<Stack, Swift.Error> {
			createStackTask?.cancel()
			let task = Task<Stack, Swift.Error> {
				defer { self.createStackTask = nil }

				createStackError = nil

				do {
					guard let stackFileContent else {
						throw Error.invalidDeploymentSettings
					}

					if let stackID {
						let stackSettings = StackUpdateSettings(
							env: stackEnvironment.map { .init(name: $0.key, value: $0.value) },
							prune: true,
							pullImage: pullImage,
							stackFileContent: stackFileContent
						)
						let updatedStack = try await PortainerStore.shared.updateStack(stackID: stackID, settings: stackSettings)
						return updatedStack
					} else {
						let stackSettings = StackDeployment.DeploymentSettings.StandaloneString(
							env: stackEnvironment.map { .init(name: $0.key, value: $0.value) },
							fromAppTemplate: nil,
							name: stackName,
							stackFileContent: stackFileContent
						)
						let createdStack = try await PortainerStore.shared.createStack(stackSettings: stackSettings)
						return createdStack
					}
				} catch {
					Task {
						createStackError = error
						try? await Task.sleep(for: .seconds(Constants.errorDismissTimeout))
						createStackError = nil
					}

					throw error
				}
			}
			self.createStackTask = task
			return task
		}

		@discardableResult
		func fetchStackFile(for stackID: Stack.ID) -> Task<Void, Swift.Error> {
			fetchStackFileTask?.cancel()
			let task = Task<Void, Swift.Error> {
				defer { self.fetchStackFileTask = nil }
				self.fetchStackFileError = nil

				do {
					let stackFileContent = try await PortainerStore.shared.fetchStackFile(stackID: stackID)
					self.stackFileContent = stackFileContent
				} catch {
					self.fetchStackFileError = error
				}
			}
			self.fetchStackFileTask = task
			return task
		}

		@discardableResult
		func loadStackFile(at url: URL, securityScopedResource: Bool) throws -> String {
			do {
				if securityScopedResource {
					guard url.startAccessingSecurityScopedResource() else {
						throw Error.unableToAccessFile
					}
				}

				let data = try Data(contentsOf: url)
				url.stopAccessingSecurityScopedResource()

				let string = String(decoding: data, as: UTF8.self)
				self.stackFileContent = string
				return string
			} catch {
				logger.error("Failed to load stack file: \(error)")
				throw error
			}
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

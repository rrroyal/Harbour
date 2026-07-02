//
//  CreateStackCreatorView+ViewModel.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import Foundation
import OSLog
import PortainerKit

// MARK: - CreateStackCreatorView+ViewModel

extension CreateStackCreatorView {
	@Observable @MainActor
	final class ViewModel {
		private let portainerStore: PortainerStore

		private(set) var createStackTask: Task<Stack, Swift.Error>?
		private(set) var createStackError: Swift.Error?

		var stackName = ""
		var stackEnvironment: [KeyValueEntry] = []

		var services: [Service] = []
		var networks: [Network] = []

		init(portainerStore: PortainerStore) {
			self.portainerStore = portainerStore
		}

		var canCreateStack: Bool {
			!stackName.isReallyEmpty &&
			!services.isEmpty &&
			services.allSatisfy { !$0.serviceName.isReallyEmpty && !$0.image.isReallyEmpty }
		}

		var isLoading: Bool {
			!(createStackTask?.isCancelled ?? true)
		}

		var serviceEditorMode: AddOrEdit<Service>?
		var networkEditorMode: AddOrEdit<Network>?
		var environmentEditorMode: AddOrEdit<KeyValueEntry>?

		func saveService(_ service: Service) {
			if let index = services.firstIndex(where: { $0.id == service.id }) {
				services[index] = service
			} else {
				services.append(service)
			}
		}

		func removeService(_ service: Service) {
			if let index = services.firstIndex(where: { $0.id == service.id }) {
				services.remove(at: index)
			}
		}

		func saveNetwork(_ network: Network) {
			if let index = networks.firstIndex(where: { $0.id == network.id }) {
				networks[index] = network
			} else {
				networks.append(network)
			}
		}

		func removeNetwork(_ network: Network) {
			if let index = networks.firstIndex(where: { $0.id == network.id }) {
				networks.remove(at: index)
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

		func createStack() -> Task<Stack, Swift.Error> {
			createStackTask?.cancel()
			let task = Task<Stack, Swift.Error> {
				defer { self.createStackTask = nil }

				createStackError = nil

				do {
					let fileContent = generateDockerComposeYAML()
					let stackSettings = StackDeployment.DeploymentSettings.StandaloneString(
						env: stackEnvironment.map { .init(name: $0.key, value: $0.value) },
						fromAppTemplate: nil,
						name: stackName.replacingOccurrences(of: " ", with: "-"),
						stackFileContent: fileContent
					)
					let createdStack = try await portainerStore.createStack(stackSettings: stackSettings)
					return createdStack
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

		@inline(always)
		func normalizeString(_ string: String, replaceSpaces: Bool = true) -> String {
			string
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.replacingOccurrences(of: " ", with: replaceSpaces ? "-" : " ")
		}

		// swiftlint:disable:next cyclomatic_complexity function_body_length
		func generateDockerComposeYAML() -> String {
			var indentationLevel = 0
			var indentation: String {
				String(repeating: " ", count: indentationLevel * 2)
			}

			var lines: [String] = [
				"services:"
			]

			for service in services {
				indentationLevel += 1

				let serviceName = normalizeString(service.serviceName)
				lines.append("\(indentation)\(serviceName):")
				indentationLevel += 1

				let serviceImage = normalizeString(service.image)
				lines.append("\(indentation)image: \"\(serviceImage)\"")

				if let containerName = service.containerName.map({ normalizeString($0, replaceSpaces: false) }) {
					lines.append("\(indentation)container_name: \"\(containerName)\"")
				}

				if !service.environment.isEmpty {
					lines.append("\(indentation)environment:")
					indentationLevel += 1

					for entry in service.environment {
						let key = normalizeString(entry.key)
						let value = normalizeString(entry.value, replaceSpaces: false)
						lines.append("\(indentation)- \"\(key)=\(value)\"")
					}

					indentationLevel -= 1
				}

				if !service.labels.isEmpty {
					lines.append("\(indentation)labels:")
					indentationLevel += 1

					for entry in service.labels {
						let key = normalizeString(entry.key)
						let value = normalizeString(entry.value, replaceSpaces: false)
						lines.append("\(indentation)- \"\(key)=\(value)\"")
					}

					indentationLevel -= 1
				}

				if !service.volumes.isEmpty {
					lines.append("\(indentation)volumes:")
					indentationLevel += 1

					for volume in service.volumes {
						let source = normalizeString(volume.source, replaceSpaces: false)
						let target = normalizeString(volume.target, replaceSpaces: false)
						lines.append("\(indentation)- \"\(source):\(target)\"")
					}

					indentationLevel -= 1
				}

				if !service.ports.isEmpty {
					lines.append("\(indentation)ports:")
					indentationLevel += 1

					for port in service.ports {
						let protoSuffix = port.proto == .tcp ? "" : "/\(port.proto.rawValue)"
						lines.append("\(indentation)- \(port.hostPort):\(port.containerPort)\(protoSuffix)")
					}

					indentationLevel -= 1
				}

				if !service.networks.isEmpty {
					lines.append("\(indentation)networks:")
					indentationLevel += 1

					for network in service.networks {
						let name = normalizeString(network.name)
						lines.append("\(indentation)- \(name)")
					}

					indentationLevel -= 1
				}

				indentationLevel -= 1
			}

			if !networks.isEmpty {
				lines.append("")
				lines.append("networks:")
				indentationLevel += 1
				for network in networks {
					let name = normalizeString(network.name)
					lines.append("\(indentationLevel)\(name):")
					indentationLevel += 1

					if network.external {
						lines.append("\(indentationLevel)external: true")
					}

					indentationLevel -= 1
				}

				indentationLevel -= 1
			}

			return lines.joined(separator: "\n")
		}
	}
}

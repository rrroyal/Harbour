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

		var services: [Service] = []
		var networks: [Network] = []

		init(portainerStore: PortainerStore) {
			self.portainerStore = portainerStore
		}

		var canCreateStack: Bool {
			!stackName.isReallyEmpty &&
			!services.isEmpty &&
			services.allSatisfy { !$0.name.isReallyEmpty && !$0.image.isReallyEmpty }
		}

		var isLoading: Bool {
			!(createStackTask?.isCancelled ?? true)
		}

		var serviceEditorMode: CreateOrEdit<Service>?
		var networkEditorMode: CreateOrEdit<Network>?

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

		func createStack() -> Task<Stack, Swift.Error> {
			createStackTask?.cancel()
			let task = Task<Stack, Swift.Error> {
				defer { self.createStackTask = nil }

				createStackError = nil

				do {
					let fileContent = generateDockerComposeYAML()
					let stackSettings = StackDeployment.DeploymentSettings.StandaloneString(
						env: [],
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

		// swiftlint:disable:next cyclomatic_complexity
		func generateDockerComposeYAML() -> String {
			var lines: [String] = ["services:"]

			for service in services {
				let safeName = service.name.isEmpty ? "service" : service.name
				lines.append("  \(safeName):")
				lines.append("    image: \(service.image)")

				if !service.environment.isEmpty {
					lines.append("    environment:")
					for entry in service.environment {
						lines.append("      - \(entry.key)=\(entry.value)")
					}
				}

				if !service.volumes.isEmpty {
					lines.append("    volumes:")
					for volume in service.volumes {
						lines.append("      - \(volume.source):\(volume.target)")
					}
				}

				if !service.ports.isEmpty {
					lines.append("    ports:")
					for port in service.ports {
						let portStr = "\(port.hostPort):\(port.containerPort)"
						let protoSuffix = port.proto == .tcp ? "" : "/\(port.proto.rawValue)"
						lines.append("      - \"\(portStr)\(protoSuffix)\"")
					}
				}

				if !service.networks.isEmpty {
					lines.append("    networks:")
					for network in service.networks {
						lines.append("      - \(network.name)")
					}
				}
			}

			if !networks.isEmpty {
				lines.append("")
				lines.append("networks:")
				for network in networks {
					lines.append("  \(network.name):")
					if network.external {
						lines.append("    external: true")
					}
				}
			}

			return lines.joined(separator: "\n")
		}
	}
}

extension CreateStackCreatorView.ViewModel {
	enum CreateOrEdit<T: Hashable>: Hashable, Identifiable {
		case create
		case edit(T)

		var id: Int {
			switch self {
			case .create: 0
			case .edit: 1
			}
		}

		var unwrapped: T? {
			switch self {
			case .create:
				nil
			case .edit(let t):
				t
			}
		}
	}
}

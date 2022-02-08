//
//  ContainerStatusIntentHandler.swift
//  Siri Intents
//
//  Created by royal on 15/01/2022.
//

import Foundation
import Intents
import PortainerKit
import Keychain

final class ContainerStatusIntentHandler: NSObject, ContainerStatusIntentHandling {
	private let portainer = Portainer.shared

	func provideContainerOptionsCollection(for intent: ContainerStatusIntent) async throws -> INObjectCollection<Container> {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)")

		try await portainer.setup()
		let containers = try await portainer.getContainers()
		let items = containers.map { Container(identifier: $0.id, display: $0.displayName ?? $0.id) }
		
		let collection = INObjectCollection(items: items)
		return collection
	}

	func resolveContainer(for intent: ContainerStatusIntent) async -> ContainerStatusContainerResolutionResult {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(intent.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")

		guard let containerID = intent.container?.identifier else { return .needsValue() }

		do {
			try await portainer.setup()
			let containers = try await portainer.getContainers(containerID: containerID)
			let filteredContainers = containers
				.filter { $0.id == intent.container?.identifier }
				.map { Container(identifier: $0.id, display: $0.displayName ?? $0.id) }

			if filteredContainers.count == 1, let container = filteredContainers.first {
				return .success(with: container)
			} else if filteredContainers.count > 1 {
				return .disambiguation(with: filteredContainers)
			} else {
				return .unsupported(forReason: .unknownContainer)
			}
		} catch {
			return .needsValue()
		}
	}
	
	func handle(intent: ContainerStatusIntent) async -> ContainerStatusIntentResponse {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(intent.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")

		guard let containerID = intent.container?.identifier else { return .failure(error: "Invalid container") }
		
		do {
			try await portainer.setup()
			let container = try await portainer.getContainers(containerID: containerID).first
			if let container = container {
				let response = ContainerStatusIntentResponse(code: .success, userActivity: nil)
				response.container = intent.container
				response.state = container.state?.asContainerStatus ?? .unknown
				response.status = container.status
				response.readableStatus = "\((container.state?.rawValue ?? "unknown").capitalizingFirstLetter) (\(container.status ?? "unknown"))"
				return response
			} else {
				return .failure(error: "Container not found")
			}
		} catch {
			return .failure(error: error.readableDescription)
		}
	}
}

extension PortainerKit.ContainerStatus {
	var asContainerStatus: ContainerStatus {
		switch self {
			case .created: return .created
			case .running: return .running
			case .paused: return .paused
			case .restarting: return .restarting
			case .removing: return .removing
			case .exited: return .exited
			case .dead: return .dead
		}
	}
}

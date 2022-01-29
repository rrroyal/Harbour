//
//  GetContainerStatusIntentHandler.swift
//  Siri Intents
//
//  Created by royal on 15/01/2022.
//

import Foundation
import Intents
import PortainerKit
import Keychain

final class GetContainerStatusIntentHandler: NSObject, GetContainerStatusIntentHandling {
	func provideContainerOptionsCollection(for intent: GetContainerStatusIntent) async throws -> INObjectCollection<Container> {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)")

		let portainer = try await Portainer.setup()
		let containers = try await portainer.getContainers()
		let items = containers.map { Container(identifier: $0.id, display: $0.displayName ?? $0.id) }
		
		let collection = INObjectCollection(items: items)
		return collection
	}

	func resolveContainer(for intent: GetContainerStatusIntent) async -> GetContainerStatusContainerResolutionResult {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(intent.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")

		guard let containerID = intent.container?.identifier else { return .needsValue() }

		do {
			let portainer = try await Portainer.setup()
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
	
	func handle(intent: GetContainerStatusIntent) async -> GetContainerStatusIntentResponse {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(intent.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")

		guard let containerID = intent.container?.identifier else { return .failure(error: "Invalid container") }
		
		do {
			let portainer = try await Portainer.setup()
			let container = try await portainer.getContainers(containerID: containerID).first
			if let container = container {
				let response = GetContainerStatusIntentResponse(code: .success, userActivity: nil)
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

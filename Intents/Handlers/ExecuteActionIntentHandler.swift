//
//  ExecuteActionIntentHandler.swift
//  Siri Intents
//
//  Created by royal on 15/01/2022.
//

import Foundation
import Intents
import PortainerKit

final class ExecuteActionIntentHandler: NSObject, ExecuteActionIntentHandling {
	private let portainer = Portainer.shared

	func provideContainerOptionsCollection(for intent: ExecuteActionIntent) async throws -> INObjectCollection<Container> {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)")

		try await portainer.setup()
		let containers = try await portainer.getContainers()
		let items = containers.map { Container(identifier: $0.id, display: $0.displayName ?? $0.id) }
		
		let collection = INObjectCollection(items: items)
		return collection
	}
	
	func resolveContainer(for intent: ExecuteActionIntent) async -> ExecuteActionContainerResolutionResult {
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
	
	func resolveAction(for intent: ExecuteActionIntent) async -> ExecuteActionActionResolutionResult {
		guard intent.action != .unknown else { return .needsValue() }
		return .success(with: intent.action)
	}
	
	func handle(intent: ExecuteActionIntent) async -> ExecuteActionIntentResponse {
		IntentHandler.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(intent.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")

		guard let action = intent.action.asPortainerAction else { return .failure(error: "Invalid action") }
		guard let containerID = intent.container?.identifier else { return .failure(error: "Invalid container") }
		
		do {
			try await portainer.setup()
			try await portainer.execute(action, on: containerID)
			return .success(newStatus: action.expectedState.asContainerStatus)
		} catch {
			return .failure(error: error.readableDescription)
		}
	}
}

extension ExecuteAction {
	var asPortainerAction: PortainerKit.ExecuteAction? {
		switch self {
			case .unknown: return nil
			case .start: return .start
			case .stop: return .stop
			case .restart: return .restart
			case .kill: return .kill
			case .pause: return .pause
			case .unpause: return .unpause
		}
	}
}

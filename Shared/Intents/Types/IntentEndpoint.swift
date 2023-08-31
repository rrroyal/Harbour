//
//  IntentEndpoint.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import OSLog
import PortainerKit

private let logger = Logger(.intents(IntentEndpoint.self))

// MARK: - IntentEndpoint

struct IntentEndpoint: AppEntity, Identifiable, Hashable {
	static var typeDisplayRepresentation: TypeDisplayRepresentation = "IntentEndpoint.TypeDisplayRepresentation"
	static var defaultQuery = IntentEndpointQuery()

	let id: Endpoint.ID
	let name: String?

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: "\(id)"))
	}

	init(id: Endpoint.ID, name: String?) {
		self.id = id
		self.name = name
	}

	init(endpoint: Endpoint) {
		self.id = endpoint.id
		self.name = endpoint.name
	}
}

// MARK: - IntentEndpoint+preview

extension IntentEndpoint {
	static func preview(
		id: Endpoint.ID = 0,
		name: Endpoint.Name? = String(localized: "IntentEndpoint.Preview.Name")
	) -> Self {
		.init(id: id, name: name)
	}
}

// MARK: - IntentEndpointQuery

struct IntentEndpointQuery: EntityQuery {
	typealias Entity = IntentEndpoint

	@IntentParameterDependency<ContainerStatusIntent>(\.$resolveOffline)
	var statusIntent

	private var resolveOffline: Bool {
		statusIntent?.resolveOffline ?? false
	}

	func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
		if resolveOffline {
			return identifiers.map { .init(id: $0, name: nil) }
		}

		do {
			let portainerStore = IntentPortainerStore.shared
			try portainerStore.setupIfNeeded()
			let endpoints = try await portainerStore.getEndpoints()

			return endpoints
				.filter { identifiers.contains($0.id) }
				.map { Entity(endpoint: $0) }
		} catch {
			logger.error("\(String(describing: error), privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			return []
		}
	}

	func suggestedEntities() async throws -> [Entity] {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()
		let endpoints = try await portainerStore.getEndpoints()
		return endpoints.map { Entity(endpoint: $0) }
	}
}

//
//  IntentEndpoint.swift
//  HarbourIntents
//
//  Created by royal on 10/06/2023.
//

import AppIntents
import PortainerKit

// MARK: - IntentEndpoint

struct IntentEndpoint: AppEntity, Identifiable {
	let id: Endpoint.ID
	let name: String?

	static var typeDisplayRepresentation: TypeDisplayRepresentation = "IntentEndpoint.TypeDisplayRepresentation"
	static var defaultQuery = IntentEndpointQuery()

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
	static func preview(id: Endpoint.ID = 0,
						name: Endpoint.Name? = String(localized: "IntentEndpoint.Preview.Name")) -> Self {
		.init(id: id, name: name)
	}
}

// MARK: - IntentEndpointQuery

struct IntentEndpointQuery: EntityQuery {
	typealias Entity = IntentEndpoint

	private let portainerStore = PortainerStore.shared

	func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
		try portainerStore.setupIfNeeded()
		let endpoints = try await portainerStore.getEndpoints()
		return endpoints
			.filter { identifiers.contains($0.id) }
			.map { Entity(endpoint: $0) }
	}

	func suggestedEntities() async throws -> [Entity] {
		try portainerStore.setupIfNeeded()
		let endpoints = try await portainerStore.getEndpoints()
		return endpoints.map { Entity(endpoint: $0) }
	}
}

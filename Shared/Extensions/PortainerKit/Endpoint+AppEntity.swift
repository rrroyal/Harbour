//
//  Endpoint+AppEntity.swift
//  Harbour
//
//  Created by royal on 15/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

// MARK: - Endpoint+AppEntity

extension Endpoint: @retroactive AppEntity {
	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Endpoint.TypeDisplayRepresentation")
	public static let defaultQuery = AppEntityQuery()

	public var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: id.description))
	}
}

// MARK: - Endpoint+Query

public extension Endpoint {
	struct AppEntityQuery: EntityQuery {
		public typealias Entity = Endpoint

		public init() { }

		public func suggestedEntities() async throws -> [Entity] {
			let portainerStore = IntentPortainerStore.shared
			try await portainerStore.setupIfNeeded()
			return try await portainerStore.portainer.fetchEndpoints()
				.sorted { $0.id < $1.id }
		}

		public func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
			let portainerStore = IntentPortainerStore.shared
			try await portainerStore.setupIfNeeded()
			return try await portainerStore.portainer.fetchEndpoints()
				.filter { identifiers.contains($0.id) }
		}
	}
}

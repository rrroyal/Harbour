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

// swiftlint:disable lower_acl_than_parent

struct IntentEndpoint: AppEntity, Identifiable {
	public static let typeDisplayRepresentation: TypeDisplayRepresentation = "IntentEndpoint.TypeDisplayRepresentation"
	public static let defaultQuery = IntentEndpointQuery()

	public var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: "\(id)"))
	}

	@Property(title: "IntentEndpoint.ID")
	public var id: Endpoint.ID

	@Property(title: "IntentEndpoint.Name")
	public var name: String?

	init(id: Endpoint.ID, name: String?) {
		self.id = id
		self.name = name
	}

	init(endpoint: Endpoint) {
		self.id = endpoint.id
		self.name = endpoint.name
	}
}

// swiftlint:enable lower_acl_than_parent

// MARK: - IntentEndpoint+Equatable

extension IntentEndpoint: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id &&
		lhs.name == rhs.name
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

// MARK: - IntentEndpoint+IntentEndpointQuery

extension IntentEndpoint {
	struct IntentEndpointQuery: EntityQuery {
		typealias Entity = IntentEndpoint

//		@IntentParameterDependency<ContainerStatusIntent>()
//		var statusIntent

		private var requiresOnline: Bool {
			// Check if in Shortcut
			false
		}

		func defaultResult() async -> Entity? {
			logger.info("Getting default result...")

			do {
				let portainerStore = IntentPortainerStore.shared
				try await portainerStore.setupIfNeeded()
				let endpoints = try await portainerStore.portainer.fetchEndpoints()

				if endpoints.count == 1, let endpoint = endpoints.first {
					logger.notice("Got one endpoint with ID: \"\(endpoint.id)\"")
					return Entity(endpoint: endpoint)
				}

				logger.notice("Endpoints count: \(endpoints.count), returning no default.")
				return nil
			} catch {
				logger.error("Error getting default result: \(error.localizedDescription, privacy: .public)")
				return nil
			}
		}

		func suggestedEntities() async throws -> [Entity] {
			logger.info("Getting suggested entities...")

			do {
				let portainerStore = IntentPortainerStore.shared
				try await portainerStore.setupIfNeeded()
				let entities = try await portainerStore.portainer.fetchEndpoints()
					.map { Entity(endpoint: $0) }
					.localizedSorted(by: \.name)

				logger.notice("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
			} catch {
				logger.error("Error getting suggested entities: \(error.localizedDescription, privacy: .public)")
				throw error
			}
		}

		func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
			logger.info("Getting entities for identifiers: \(identifiers)...")

			do {
				let portainerStore = IntentPortainerStore.shared
				try await portainerStore.setupIfNeeded()

				let entities = try await portainerStore.portainer.fetchEndpoints()
					.filter { identifiers.contains($0.id) }
					.map { Entity(endpoint: $0) }
					.localizedSorted(by: \.name)

				logger.notice("Returning \(entities.count) entities (live)")
				return entities
			} catch {
				logger.error("Error getting entities: \(error.localizedDescription, privacy: .public)")

				if !requiresOnline && error is URLError {
					let parsed = identifiers.map { Entity(id: $0, name: nil) }
					logger.notice("Returning \(parsed.count) entities (parsed)")
					return parsed
				}

				throw error
			}
		}
	}
}

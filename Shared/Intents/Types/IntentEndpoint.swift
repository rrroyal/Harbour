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

struct IntentEndpoint: AppEntity, Identifiable {
	public static let typeDisplayRepresentation: TypeDisplayRepresentation = "IntentEndpoint.TypeDisplayRepresentation"
	public static let defaultQuery = Query()

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

// MARK: - IntentEndpoint+Query

extension IntentEndpoint {
	struct Query: EntityQuery {
		typealias Entity = IntentEndpoint

		//	@IntentParameterDependency<ContainerStatusIntent>()
		//	var statusIntent

		private var requiresOnline: Bool {
			// Check if in Shortcut
			false
		}

		func suggestedEntities() async throws -> [Entity] {
			let portainerStore = IntentPortainerStore.shared
			try portainerStore.setupIfNeeded()
			let endpoints = try await portainerStore.getEndpoints()
			return endpoints
				.map { Entity(endpoint: $0) }
				.sorted { $0.id < $1.id }
		}

		func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
			logger.info("Getting entities for identifiers: \(String(describing: identifiers), privacy: .sensitive)...")

			do {
				let portainerStore = IntentPortainerStore.shared
				try portainerStore.setupIfNeeded()

				let endpoints = try await portainerStore.getEndpoints()
					.filter { identifiers.contains($0.id) }
					.map { Entity(endpoint: $0) }

				logger.info("Returning \(String(describing: endpoints), privacy: .sensitive) (live)")
				return endpoints
			} catch {
				logger.error("Error getting entities: \(error, privacy: .public)")

				if !requiresOnline && error is URLError {
					let parsed = identifiers.map { Entity(id: $0, name: nil) }
					logger.notice("Returning \(String(describing: parsed), privacy: .sensitive) (offline)")
					return parsed
				}

				throw error
			}
		}
	}
}

//
//  IntentContainer.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import OSLog
import PortainerKit

private let logger = Logger(.intents(IntentContainer.self))

// MARK: - IntentContainer

struct IntentContainer: AppEntity, Hashable {
	static var typeDisplayRepresentation: TypeDisplayRepresentation = "IntentContainer.TypeDisplayRepresentation"
	static var defaultQuery = IntentContainerQuery()

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: _id))
	}

	/// Actual container ID
	let _id: Container.ID
	let name: String?
	let imageID: String?
	let associationID: String?

	init(id: Container.ID, name: String?, imageID: String?, associationID: String?) {
		self._id = id
		self.name = name
		self.imageID = imageID
		self.associationID = associationID
	}

	init(container: Container) {
		self._id = container.id
		self.name = container.displayName
		self.imageID = container.imageID
		self.associationID = container.associationID
	}
}

// MARK: - IntentContainer+Identifiable

extension IntentContainer: Identifiable {
	private static let partJoiner = ";"

	/// Container ID + display name
	var id: String {
		[_id, name ?? "", imageID ?? "", associationID ?? ""].joined(separator: Self.partJoiner)
	}

	init?(id: String) {
		let parts = id.split(separator: Self.partJoiner)
		if parts.count == 4 {
			self.init(
				id: String(parts[0]),
				name: String(parts[1]),
				imageID: String(parts[2]),
				associationID: String(parts[3])
			)
			return
		}

		if let first = parts[safe: 0] {
			self.init(
				id: String(first),
				name: nil,
				imageID: nil,
				associationID: nil
			)
			return
		}

		return nil
	}
}

// MARK: - IntentContainer+Static

extension IntentContainer {
	static func preview(
		id: String = "PreviewContainerID",
		name: String = String(localized: "IntentContainer.Preview.Name")
	) -> Self {
		.init(id: id, name: name, imageID: nil, associationID: nil)
	}
}

// MARK: - IntentContainerQuery

struct IntentContainerQuery: EntityStringQuery {
	typealias Entity = IntentContainer

	@IntentParameterDependency<ContainerStatusIntent>(\.$endpoint, \.$resolveByName)
	var statusIntent

	private var endpoint: IntentEndpoint? {
		statusIntent?.endpoint
	}

	private var resolveByName: Bool {
		statusIntent?.resolveByName ?? false
	}

	private var requiresOnline: Bool {
		// Check if in Shortcut
		false
	}

	func suggestedEntities() async throws -> [Entity] {
		do {
			guard let endpoint else { return [] }

			let containers = try await getContainers(for: endpoint.id, resolveByName: resolveByName)
			return containers.map { Entity(container: $0) }
		} catch {
			logger.error("Error getting suggested entities: \(error, privacy: .public)")
			throw error
		}
	}

	func entities(matching string: String) async throws -> [Entity] {
		do {
			guard let endpoint else {
				logger.notice("Returning empty (no endpoint) [\(String._debugInfo(), privacy: .public)]")
				return []
			}

			// TODO: Filter in request

			let containers = try await _getContainers(for: endpoint.id)
				.filter(string)
				.sorted()
				.map { Entity(container: $0) }

			if containers.isEmpty {
				logger.notice("Returning empty (empty query) [\(String._debugInfo(), privacy: .public)]")
				return []
			}

			logger.info("Returning \(String(describing: containers), privacy: .sensitive) (live) [\(String._debugInfo(), privacy: .public)]")
			return containers
		} catch {
			logger.error("Error getting matching entities: \(error, privacy: .public)")
			throw error
		}
	}

	func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {

		guard let endpoint else {
			logger.notice("Returning empty (no endpoint) [\(String._debugInfo(), privacy: .public)]")
			return []
		}

		let parsed = identifiers.compactMap { Entity(id: $0) }
		let (parsedIDs, parsedNames, parsedAssociationIDs, parsedImageIDs) = (
			parsed.map(\._id),
			parsed.map(\.name),
			parsed.map(\.associationID),
			parsed.map(\.imageID)
		)

		do {
			let containers = try await _getContainers(for: endpoint.id)
				.filter {
					parsedIDs.contains($0.id) || parsedNames.contains($0.displayName) || parsedAssociationIDs.contains($0.associationID) || parsedImageIDs.contains($0.imageID)
				}
				.map { Entity(container: $0) }

			logger.info("Returning \(String(describing: containers), privacy: .sensitive) (live) [\(String._debugInfo(), privacy: .public)]")

			if containers.isEmpty {
				logger.notice("Returning empty (empty query) [\(String._debugInfo(), privacy: .public)]")
				return []
			}

			return containers
		} catch {
			logger.error("Error getting entities: \(error, privacy: .public)")

			if !requiresOnline && error is URLError {
				logger.notice("Returning \(String(describing: parsed), privacy: .sensitive) (offline) [\(String._debugInfo(), privacy: .public)]")
				return parsed
			}

			throw error
		}
	}
}

// MARK: - IntentContainerQuery+Static

extension IntentContainerQuery {
	func getContainers(
		for endpointID: Endpoint.ID,
		ids: [Container.ID]? = nil,
		names: [String?]? = nil,
		resolveByName: Bool
	) async throws -> [Container] {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()

		let filters = Portainer.FetchFilters(
			id: resolveByName ? nil : ids,
			name: resolveByName ? names?.compactMap { $0 } : nil
		)
		let containers = try await portainerStore.getContainers(for: endpointID, filters: filters)

		return containers
	}

	func _getContainers(for endpointID: Endpoint.ID) async throws -> [Container] {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()
		return try await portainerStore.getContainers(for: endpointID)
	}
}

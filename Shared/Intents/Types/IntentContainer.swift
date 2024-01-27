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
	var _id: Container.ID
	var name: String?
	var image: String?
	var associationID: String?

	init(id: Container.ID, name: String?, image: String?, associationID: String?) {
		self._id = id
		self.name = name
		self.image = image
		self.associationID = associationID
	}

	init(container: Container) {
		self._id = container.id
		self.name = container.displayName
		self.image = container.image
		self.associationID = container.associationID
	}
}

// MARK: - IntentContainer+Identifiable

extension IntentContainer: Identifiable {
	private static let partJoiner = ";"

	/// Container ID + display name
	var id: String {
		[_id, name ?? "", image ?? "", associationID ?? ""].joined(separator: Self.partJoiner)
	}

	static func fromID(_ id: String) -> Self? {
		let parts = id.split(separator: Self.partJoiner)

		let id: String? = if let id = parts[safe: 0] { String(id) } else { nil }
		let name: String? = if let name = parts[safe: 1] { String(name) } else { nil }
		let image: String? = if let image = parts[safe: 2] { String(image) } else { nil }
		let associationID: String? = if let associationID = parts[safe: 3] { String(associationID) } else { nil }

		if let id {
			return self.init(
				id: id,
				name: name,
				image: image,
				associationID: associationID
			)
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
		.init(id: id, name: name, image: nil, associationID: nil)
	}
}

// MARK: - IntentContainer+matchesContainer

extension IntentContainer {
	func matchesContainer(_ container: Container) -> Bool {
		self._id == container.id || (self.associationID != nil && self.associationID == container.associationID) || self.image == container.image || self.name == container.displayName
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
		statusIntent?.resolveByName ?? true
	}

	private var requiresOnline: Bool {
		// Check if in Shortcut
		false
	}

	func suggestedEntities() async throws -> [Entity] {
		do {
			guard let endpoint else { return [] }

			let containers = try await getContainers(for: endpoint.id)
			return containers.map { Entity(container: $0) }
		} catch {
			logger.error("Error getting suggested entities: \(error, privacy: .public)")
			throw error
		}
	}

	func entities(matching string: String) async throws -> [Entity] {
		logger.info("Getting entities matching \"\(string, privacy: .sensitive)\"...")

		do {
			guard let endpoint else {
				logger.notice("Returning empty (no endpoint)")
				return []
			}

			let containers = try await getContainers(for: endpoint.id)
				.filter(string)
				.sorted()
				.map { Entity(container: $0) }

			logger.notice("Returning \(String(describing: containers), privacy: .sensitive) (live)")
			return containers
		} catch {
			logger.error("Error getting matching entities: \(error, privacy: .public)")
			throw error
		}
	}

	func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
		logger.info("Getting entities for identifiers: \(String(describing: identifiers), privacy: .sensitive)...")

		guard let endpoint else {
			logger.notice("Returning empty (no endpoint)")
			return []
		}

		let parsedContainers = identifiers.compactMap { Entity.fromID($0) }

		do {
			let entities: [Entity] = try await {
				if requiresOnline {
					let filters = FetchFilters(
						id: resolveByName ? nil : parsedContainers.map(\._id)
					)
					return try await getContainers(for: endpoint.id, filters: filters)
						.filter { container in
							if resolveByName {
								return parsedContainers.contains { $0.matchesContainer(container) }
							} else {
								return parsedContainers.contains { $0._id == container.id }
							}
						}
						.compactMap { container in
							let entity = Entity(container: container)
							return entity
						}
				} else {
					return parsedContainers
				}
			}()

			logger.notice("Returning \(String(describing: entities), privacy: .sensitive) (\(requiresOnline ? "live" : "parsed"))")

			return entities
		} catch {
			logger.error("Error getting entities: \(error, privacy: .public)")

			if !requiresOnline && error is URLError {
				logger.notice("Returning \(String(describing: parsedContainers), privacy: .sensitive) (offline)")
				return parsedContainers
			}

			throw error
		}
	}
}

// MARK: - IntentContainerQuery+Static

extension IntentContainerQuery {
	func getContainers(
		for endpointID: Endpoint.ID,
		filters: FetchFilters? = nil
	) async throws -> [Container] {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()
		let containers = try await portainerStore.getContainers(for: endpointID, filters: filters)
		return containers
	}
}

//
//  IntentContainer.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//

import AppIntents
import PortainerKit

// MARK: - IntentContainer

struct IntentContainer: AppEntity, Identifiable, Hashable {
	/// Actual container ID
	let _id: Container.ID

	/// Container ID + display name
	let id: String

	/// Container display name
	let name: String?

	static var typeDisplayRepresentation: TypeDisplayRepresentation = "IntentContainer.TypeDisplayRepresentation"
	static var defaultQuery = IntentContainerQuery()

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: _id))
	}

	init(id: Container.ID, name: String?) {
		self._id = id
		self.id = id
		self.name = name
	}

	init(container: Container) {
		self._id = container.id
		self.id = "\(container.id):\(container.displayName ?? "")"
		self.name = container.displayName
	}
}

// MARK: - IntentContainer+preview

extension IntentContainer {
	static func preview(id: String = "PreviewContainerID",
						name: String = String(localized: "IntentContainer.Preview.Name")) -> Self {
		.init(id: id, name: name)
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

	func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
		guard let endpoint else { return [] }

		let parsed: [(Container.ID, Container.Name?)] = identifiers
			.compactMap {
				// <containerID>:<containerName>
				let parts = $0.split(separator: ":")
				if parts.count == 2 {
					return (String(parts[0]), String(parts[1]))
				}

				if resolveByName {
					// Ignore container, as we only want names
					return nil
				}

				if let first = parts[safe: 0] {
					return (String(first), nil)
				}

				return ($0, nil)
			}

		let ids = parsed.map(\.0)
		let names = parsed.map(\.1)

		let containers = try await getContainers(for: endpoint.id,
												 ids: ids,
												 names: names,
												 resolveByName: resolveByName)
		return containers.map { Entity(container: $0) }
	}

	func entities(matching string: String) async throws -> [Entity] {
		guard let endpoint else { return [] }

		let containers = try await getContainers(for: endpoint.id,
												 resolveByName: resolveByName)
		return containers
			.filtered(string)
			.map { Entity(container: $0) }
	}

	func suggestedEntities() async throws -> [Entity] {
		guard let endpoint else { return [] }

		let containers = try await getContainers(for: endpoint.id,
												 resolveByName: resolveByName)
		return containers.map { Entity(container: $0) }
	}
}

// MARK: - IntentContainerQuery+Static

extension IntentContainerQuery {
	func getContainers(for endpointID: Endpoint.ID,
					   ids: [Container.ID]? = nil,
					   names: [Container.Name?]? = nil,
					   resolveByName: Bool) async throws -> [Container] {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()

		let filters = IntentPortainerStore.filters(
			for: ids,
			names: names,
			resolveByName: resolveByName
		)
		let containers = try await portainerStore.getContainers(for: endpointID, filters: filters)
		return containers
	}
}

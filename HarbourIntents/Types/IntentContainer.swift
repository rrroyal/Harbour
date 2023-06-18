//
//  IntentContainer.swift
//  HarbourIntents
//
//  Created by royal on 10/06/2023.
//

import AppIntents
import PortainerKit

// MARK: - IntentContainer

struct IntentContainer: AppEntity, Identifiable, Hashable {
	let id: Container.ID
	let name: String?

	static var typeDisplayRepresentation: TypeDisplayRepresentation = "IntentContainer.TypeDisplayRepresentation"
	static var defaultQuery = IntentContainerQuery()

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: id))
	}

	init(id: Container.ID, name: String?) {
		self.id = id
		self.name = name
	}

	init(container: Container) {
		self.id = container.id
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

	private let portainerStore = PortainerStore.shared

	private var endpoint: IntentEndpoint? {
		statusIntent?.endpoint
	}

	private var resolveByName: Bool {
		statusIntent?.resolveByName ?? false
	}

	func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
		guard let endpoint else { return [] }

		let containers = try await getContainers(for: endpoint.id,
												 containerIDs: identifiers,
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

// MARK: - IntentContainerQuery+Private

private extension IntentContainerQuery {
	func getContainers(for endpointID: Endpoint.ID,
					   containerIDs: [Container.ID]? = nil,
					   containerNames: [Container.Name]? = nil,
					   resolveByName: Bool) async throws -> [Container] {
		try portainerStore.setupIfNeeded()

		let filters = PortainerStore.filters(for: containerIDs,
											 names: containerNames,
											 resolveByName: resolveByName)
		let containers = try await portainerStore.getContainers(for: endpointID, filters: filters)
		return containers
	}
}

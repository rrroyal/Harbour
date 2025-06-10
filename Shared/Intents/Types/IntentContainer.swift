//
//  IntentContainer.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import CommonOSLog
import OSLog
import PortainerKit

private let logger = Logger(.intents(IntentContainer.self))

// MARK: - IntentContainer

// swiftlint:disable lower_acl_than_parent

struct IntentContainer: AppEntity {
	public static let typeDisplayRepresentation: TypeDisplayRepresentation = "IntentContainer.TypeDisplayRepresentation"
	public static let defaultQuery = IntentContainerQuery()

	public var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: _id))
	}

	@Property(title: "IntentContainer.ID")
	public var _id: Container.ID

	@Property(title: "IntentContainer.Name")
	public var name: String?

	@Property(title: "IntentContainer.ContainerState")
	public var state: ContainerStateAppEnum?

	@Property(title: "IntentContainer.Status")
	public var status: String?

	public var persistentID: String?

	init(
		id: Container.ID,
		name: String?,
		containerState: Container.State? = nil,
		status: String? = nil,
		persistentID: String? = nil
	) {
		self._id = id
		self.name = name
		if let containerState {
			self.state = .init(state: containerState)
		} else {
			self.state = nil
		}
		self.status = status
		self.persistentID = persistentID
	}

	init(container: Container) {
		self._id = container.id
		self.name = container.displayName
		if let containerState = container.state {
			self.state = .init(state: containerState)
		} else {
			self.state = nil
		}
		self.status = container.status
		self.persistentID = container._persistentID
	}
}

// swiftlint:enable lower_acl_than_parent

// MARK: - IntentContainer+Identifiable

extension IntentContainer: Identifiable {
	private static let partJoiner = ";"

	var id: String {
		[_id, name ?? "", persistentID ?? ""].joined(separator: Self.partJoiner)
	}

	init?(id: String) {
		let parts = id.split(separator: Self.partJoiner)

		let id: String? = if let id = parts[safe: 0] { String(id) } else { nil }
		guard let id else { return nil }

		let name: String? = if let str = parts[safe: 1] { String(str) } else { nil }
		let persistentID: String? = if let str = parts[safe: 2] { String(str) } else { nil }

		self.init(
			id: id,
			name: name,
			persistentID: persistentID
		)
	}
}

// MARK: - IntentContainer+Equatable

extension IntentContainer: Equatable {
	static func == (lhs: IntentContainer, rhs: IntentContainer) -> Bool {
		(lhs.persistentID != nil && lhs.persistentID == rhs.persistentID) ||
		(lhs.id == rhs.id && lhs.name == rhs.name)
	}
}

// MARK: - IntentContainer+Static

extension IntentContainer {
	static func preview(
		id: String = "PreviewContainerID",
		name: String = String(localized: "IntentContainer.Preview.Name")
	) -> Self {
		.init(id: id, name: name)
	}
}

// MARK: - IntentContainer+matchesContainer

extension IntentContainer {
	func matchesContainer(_ container: Container) -> Bool {
		self._id == container.id ||
		(self.persistentID != nil && self.persistentID == container._persistentID) ||
		self.name == container.displayName
	}
}

// MARK: - IntentContainer+IntentContainerQuery

extension IntentContainer {
	struct IntentContainerQuery: EntityStringQuery {
		typealias Entity = IntentContainer

		#if TARGET_WIDGETS
		@IntentParameterDependency<ContainerStatusWidget.Intent>(\.$endpoint, \.$resolveStrictly)
		var containerStatusWidgetIntent
		#else
		@IntentParameterDependency<ContainerActionIntent>(\.$endpoint)
		var containerActionIntent

		@IntentParameterDependency<ContainerStatusIntent>(\.$endpoint, \.$resolveStrictly)
		var containerStatusIntent
		#endif

		private var endpoint: IntentEndpoint? {
			#if TARGET_WIDGETS
			containerStatusWidgetIntent?.endpoint
			#else
			containerActionIntent?.endpoint ?? containerStatusIntent?.endpoint
			#endif
		}

		private var resolveStrictly: Bool {
			#if TARGET_WIDGETS
			containerStatusWidgetIntent?.resolveStrictly ?? false
			#else
			containerStatusIntent?.resolveStrictly ?? false
			#endif
		}

		private var requiresOnline: Bool {
			#if TARGET_WIDGETS
			false
			#else
			containerActionIntent != nil
			#endif
		}

		func suggestedEntities() async throws -> [Entity] {
			logger.info("Getting suggested entities...")

			do {
				guard let endpoint else {
					logger.info("Returning empty (no endpoint)")
					return []
				}

				let portainerStore = IntentPortainerStore.shared
				try await portainerStore.setupIfNeeded()
				let entities = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id)
					.map { Entity(container: $0) }
					.localizedSorted(by: \.name)

				logger.info("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
			} catch {
				logger.error("Error getting suggested entities: \(error.localizedDescription, privacy: .public)")
				throw error
			}
		}

		func entities(matching string: String) async throws -> [Entity] {
			logger.info("Getting entities matching \"\(string)\"...")

			do {
				guard let endpoint else {
					logger.info("Returning empty (no endpoint)")
					return []
				}

				let portainerStore = IntentPortainerStore.shared
				try await portainerStore.setupIfNeeded()
				let entities = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id)
					.filter(string)
					.map { Entity(container: $0) }
					.localizedSorted(by: \.name)

				logger.info("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
			} catch {
				logger.error("Error getting matching entities: \(error.localizedDescription, privacy: .public)")
				throw error
			}
		}

		func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
			logger.info("Getting entities for identifiers: \(identifiers)...")

			guard let endpoint else {
				logger.info("Returning empty (no endpoint)")
				return []
			}

			let parsedContainers = identifiers.compactMap { Entity(id: $0) }

			do {
				let entities: [Entity] = try await {
					if requiresOnline {
						let portainerStore = IntentPortainerStore.shared
						try await portainerStore.setupIfNeeded()

						let filters = FetchFilters(
							id: resolveStrictly ? parsedContainers.map(\._id) : nil
						)
						return try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id, filters: filters)
							.filter { container in
								if resolveStrictly {
									parsedContainers.contains { $0._id == container.id }
								} else {
									parsedContainers.contains { $0.matchesContainer(container) }
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

				logger.info("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
					.localizedSorted(by: \.name)
			} catch {
				logger.error("Error getting entities: \(error.localizedDescription, privacy: .public)")

				if !requiresOnline && error is URLError {
					logger.info("Returning \(String(describing: parsedContainers), privacy: .sensitive) (offline)")
					return parsedContainers
				}

				throw error
			}
		}
	}
}

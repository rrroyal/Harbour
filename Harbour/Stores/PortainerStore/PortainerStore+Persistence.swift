//
//  PortainerStore+Persistence.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import PortainerKit
import SwiftData

// MARK: - PortainerStore+Credentials

extension PortainerStore {
	/// Loads authorization token for saved server if available.
	/// - Returns: Credentials for Portainer
	func getStoredCredentials() -> (url: URL, token: String)? {
		logger.info("Looking for credentials...")
		do {
			guard let selectedServerURL = Preferences.shared.selectedServer else {
				logger.warning("No selected server")
				return nil
			}

			let token = try keychain.getString(for: selectedServerURL)
//			logger.info("Got token for URL: \"\(selectedServerURL.absoluteString, privacy: .sensitive(mask: .hash))\"")
			return (selectedServerURL, token)
		} catch {
			logger.warning("Failed to load token: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

// MARK: - PortainerStore+Endpoints

extension PortainerStore {
	func storeEndpoints(_ endpoints: [Endpoint]?) {
		logger.debug("Storing \(endpoints?.count ?? 0, privacy: .public) endpoints...")

		guard let modelActor else {
			logger.warning("No `modelActor` set!")
			return
		}

		do {
			try modelActor.store(endpoints) { existingIDs in
				#Predicate<StoredEndpoint> {
					!existingIDs.contains($0.id)
				}
			}
			logger.debug("Stored \(endpoints?.count ?? 0, privacy: .public) endpoints.")
		} catch {
			logger.error("Failed to store endpoints: \(error.localizedDescription, privacy: .public)")
		}
	}

	func fetchStoredEndpoints() -> [Endpoint]? {
		logger.debug("Fetching stored endpoints...")

		guard let modelActor else {
			logger.warning("No `modelActor` set!")
			return nil
		}

		do {
			let items: [Endpoint] = try modelActor.fetch()
				.sorted {
					let a = $0.name ?? "\($0.id)"
					let b = $1.name ?? "\($1.id)"
					return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
				}
			logger.debug("Got \(items.count, privacy: .public) stored endpoints.")
			return items
		} catch {
			logger.error("Failed to load stored endpoints: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

// MARK: - PortainerStore+Containers

extension PortainerStore {
	func storeContainers(_ containers: [Container]?) {
		logger.debug("Storing \(containers?.count ?? 0, privacy: .public) containers...")

		guard let modelActor else {
			logger.warning("No `modelActor` set!")
			return
		}

		do {
			try modelActor.store(containers) { existingIDs in
				#Predicate<StoredContainer> {
					!existingIDs.contains($0.id)
				}
			}
			logger.debug("Stored \(containers?.count ?? 0, privacy: .public) containers.")
		} catch {
			logger.error("Failed to store containers: \(error.localizedDescription, privacy: .public)")
		}
	}

	func fetchStoredContainers() -> [Container]? {
		logger.debug("Fetching stored containers...")

		guard let modelActor else {
			logger.warning("No `modelActor` set!")
			return nil
		}

		do {
			let items: [Container] = try modelActor.fetch()
				.sorted {
					let a = $0.displayName ?? $0.id
					let b = $1.displayName ?? $1.id
					return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
				}
			logger.debug("Got \(items.count, privacy: .public) stored containers.")
			return items
		} catch {
			logger.error("Failed to load stored containers: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

// MARK: - PortainerStore+Stacks

extension PortainerStore {
	func storeStacks(_ stacks: [Stack]?) {
		logger.debug("Storing \(stacks?.count ?? 0, privacy: .public) stacks...")

		guard let modelActor else {
			logger.warning("No `modelActor` set!")
			return
		}

		do {
			try modelActor.store(stacks) { existingIDs in
				#Predicate<StoredStack> {
					!existingIDs.contains($0.id)
				}
			}
			logger.debug("Stored \(stacks?.count ?? 0, privacy: .public) stacks.")
		} catch {
			logger.error("Failed to store stacks: \(error.localizedDescription, privacy: .public)")
		}
	}

	func fetchStoredStacks() -> [Stack]? {
		logger.debug("Fetching stored stacks...")

		guard let modelActor else {
			logger.warning("No `modelActor` set!")
			return nil
		}

		do {
			let items: [Stack] = try modelActor.fetch()
				.sorted(by: \.name)
			logger.debug("Got \(items.count, privacy: .public) stored stacks.")
			return items
		} catch {
			logger.error("Failed to load stored stacks: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

extension PortainerStore {
//	@SwiftData.ModelActor
	@MainActor
	final class ModelActor {
		private let logger = Logger(.custom(ModelActor.self))
		private var tasks: [String: Task<Void, Error>] = [:]
		private let saveBufferDuration: Duration = .seconds(2)

		let modelContext: ModelContext

		init(modelContext: ModelContext) {
			self.modelContext = modelContext
		}

		func store<S: Storable>(
			_ storables: [S]?,
			deletePredicate: @Sendable @escaping (Set<S.ID>) -> Predicate<S.Stored>
		) throws where S.ID == S.Stored.ID {
			let taskID = "\(S.Stored.self)"
			tasks[taskID]?.cancel()

			let task = Task(name: taskID) {
				guard let storables, !storables.isEmpty else {
					try modelContext.delete(model: S.Stored.self)
					try save()
					return
				}

				let existingIDs = Set(storables.map(\.id))
				try modelContext.delete(model: S.Stored.self, where: deletePredicate(existingIDs))

				for storable in storables {
					let stored = storable.toStored()
					modelContext.insert(stored)
				}

				try await Task.sleep(for: saveBufferDuration)
				do {
					try Task.checkCancellation()
					try save()
				} catch {
					logger.warning("Task \(taskID, privacy: .public) cancelled or failed saving, rolling back!")
					modelContext.rollback()
				}
			}
			tasks[taskID] = task
		}

		func fetch<S: Storable>(
			descriptor: FetchDescriptor<S.Stored> = .init()
		) throws -> [S] {
			let stored = try modelContext.fetch(descriptor)
			return stored.map { S.fromStored($0) }
		}

		func save() throws {
			if modelContext.hasChanges {
				try modelContext.save()
			}
		}
	}
}

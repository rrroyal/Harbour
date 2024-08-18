//
//  PortainerStore+Persistence.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

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
			guard let selectedServer = preferences.selectedServer,
				  let selectedServerURL = URL(string: selectedServer) else {
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
//		logger.debug("Storing \(endpoints?.count ?? 0, privacy: .public) endpoints...")

		Task { @MainActor in
			guard let modelContext else {
				logger.warning("No `modelContext` set!")
				return
			}

			do {
				guard let endpoints, !endpoints.isEmpty else {
					try modelContext.delete(model: StoredEndpoint.self)
					return
				}

				let existingIDs = Set(endpoints.map(\.id))
				let nonExistingPredicate = #Predicate<StoredEndpoint> {
					!existingIDs.contains($0.id)
				}
				try modelContext.delete(model: StoredEndpoint.self, where: nonExistingPredicate)

				for endpoint in endpoints {
					let storedContainer = StoredEndpoint(endpoint: endpoint)
					modelContext.insert(storedContainer)
				}

				try modelContext.save()

//				logger.debug("Stored \(endpoints.count, privacy: .public) endpoints.")
			} catch {
				logger.error("Failed to store endpoints: \(error.localizedDescription, privacy: .public)")
			}
		}
	}

	func fetchStoredEndpoints() -> [Endpoint]? {
//		logger.debug("Loading stored endpoints...")

		guard let modelContext else {
			logger.warning("No `modelContext` set!")
			return nil
		}

		do {
			let descriptor = FetchDescriptor<StoredEndpoint>(sortBy: [.init(\.name)])
			let items = try modelContext.fetch(descriptor)

//			logger.debug("Got \(items.count, privacy: .public) stored endpoints.")

			return items.map { .init(storedEndpoint: $0) }
		} catch {
			logger.error("Failed to load stored endpoints: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

// MARK: - PortainerStore+Containers

extension PortainerStore {
	/// Stores containers to SwiftData.
	/// - Parameter containers: Containers to store
	func storeContainers(_ containers: [Container]?) {
//		logger.debug("Storing \(containers?.count ?? 0, privacy: .public) containers...")

		Task { @MainActor in
			guard let modelContext else {
				logger.warning("No `modelContext` set!")
				return
			}

			do {
				guard let containers, !containers.isEmpty else {
					try modelContext.delete(model: StoredContainer.self)
					return
				}

				let existingIDs = Set(containers.map(\.id))
				let nonExistingPredicate = #Predicate<StoredContainer> {
					!existingIDs.contains($0.id)
				}
				try modelContext.delete(model: StoredContainer.self, where: nonExistingPredicate)

				for container in containers {
					let storedContainer = StoredContainer(container: container)
					modelContext.insert(storedContainer)
				}

				try modelContext.save()

//				logger.debug("Stored \(containers.count, privacy: .public) containers.")
			} catch {
				logger.error("Failed to store containers: \(error.localizedDescription, privacy: .public)")
			}
		}
	}

	/// Fetches stored containers and returns them.
	/// - Returns: Mapped [Container] from SwiftData.
	func fetchStoredContainers() -> [Container]? {
//		logger.debug("Loading stored containers...")

		guard let modelContext else {
			logger.warning("No `modelContext` set!")
			return nil
		}

		do {
			let descriptor = FetchDescriptor<StoredContainer>(sortBy: [.init(\.name)])
			let items = try modelContext.fetch(descriptor)

//			logger.debug("Got \(items.count, privacy: .public) stored containers.")

			return items.map { .init(storedContainer: $0) }
		} catch {
			logger.error("Failed to load stored containers: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

// MARK: - PortainerStore+Stacks

extension PortainerStore {
	func storeStacks(_ stacks: [Stack]?) {
		Task { @MainActor in
			guard let modelContext else {
				logger.warning("No `modelContext` set!")
				return
			}

			do {
				guard let stacks, !stacks.isEmpty else {
					try modelContext.delete(model: StoredStack.self)
					return
				}

				let existingIDs = Set(stacks.map(\.id))
				let nonExistingPredicate = #Predicate<StoredStack> {
					!existingIDs.contains($0.id)
				}
				try modelContext.delete(model: StoredStack.self, where: nonExistingPredicate)

				for stack in stacks {
					let storedStack = StoredStack(stack: stack)
					modelContext.insert(storedStack)
				}

				try modelContext.save()
			} catch {
				logger.error("Failed to store stacks: \(error.localizedDescription, privacy: .public)")
			}
		}
	}

	func fetchStoredStacks() -> [Stack]? {
		guard let modelContext else {
			logger.warning("No `modelContext` set!")
			return nil
		}

		do {
			let descriptor = FetchDescriptor<StoredStack>(sortBy: [.init(\.name)])
			let items = try modelContext.fetch(descriptor)

			return items.map { .init(storedStack: $0) }
		} catch {
			logger.error("Failed to load stored stacks: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}

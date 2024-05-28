//
//  PortainerStore+Refresh.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension PortainerStore {
	/// Refreshes endpoints, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Returns: `Task<[Endpoint], Error>` of refresh
	@discardableResult
	func refreshEndpoints() -> Task<[Endpoint], Error> {
		endpointsTask?.cancel()
		let task = Task { @MainActor in
			defer { self.endpointsTask = nil }

			do {
				let endpoints = try await fetchEndpoints().sorted()
				self.setEndpoints(endpoints)
				return endpoints
			} catch {
				guard !error.isCancellationError else { return self.endpoints }
				throw error
			}
		}
		self.endpointsTask = task
		return task
	}

	/// Refreshes containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Returns: `Task<[Container], Error>` of refresh
	@discardableResult
	func refreshContainers() -> Task<[Container], Error> {
		containersTask?.cancel()
		let task = Task { @MainActor in
			defer { self.containersTask = nil }

			do {
				let containers = try await self.fetchContainers().sorted()
				self.setContainers(containers)
				return containers
			} catch {
				guard !error.isCancellationError else { return self.containers }
				throw error
			}
		}
		self.containersTask = task
		return task
	}

	/// Refreshes containers with specified IDs, handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - ids: Container IDs to refresh
	/// - Returns: `Task<[Container], Error>` of refresh.
	@discardableResult
	func refreshContainers(ids: [Container.ID]) -> Task<[Container], Error> {
		let task = Task { @MainActor in
			do {
				let containers = try await self.fetchContainers(filters: .init(id: ids))
				Task { @MainActor in
					for container in containers {
						if let index = self.containers.firstIndex(where: { $0.id == container.id }) {
							self.containers[index] = container
						}
					}
				}
				return containers
			} catch {
				throw error
			}
		}
		return task
	}

	/// Refreshes stacks, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Returns: `Task<[Stack], Error>` of refresh
	@discardableResult
	func refreshStacks() -> Task<[Stack], Error> {
		stacksTask?.cancel()
		let task = Task { @MainActor in
			defer { self.stacksTask = nil }

			do {
				let stacks = try await fetchStacks().sorted()
				self.setStacks(stacks)
				return stacks
			} catch {
				guard !error.isCancellationError else { return self.stacks }
				throw error
			}
		}
		self.stacksTask = task
		return task
	}
}

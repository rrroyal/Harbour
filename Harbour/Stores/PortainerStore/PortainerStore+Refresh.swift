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
	/// Refreshes endpoints and containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<Void, Error>` of refresh.
	@discardableResult
	func refresh(
		errorHandler: ErrorHandler? = nil
	) -> Task<([Endpoint], [Container], [Stack]), Error> {
		self.refreshTask?.cancel()

		let task = Task { @MainActor in
			defer { self.refreshTask = nil }

			do {
				if selectedEndpoint != nil {
					async let _endpoints = refreshEndpoints(errorHandler: errorHandler).value
					async let _containers = refreshContainers(errorHandler: errorHandler).value
					async let _stacks = refreshStacks(errorHandler: errorHandler).value

					return try await (_endpoints, _containers, _stacks)
				} else {
					let _endpoints = try await refreshEndpoints(errorHandler: errorHandler).value

					async let _containers = refreshContainers(errorHandler: errorHandler).value
					async let _stacks = refreshStacks(errorHandler: errorHandler).value

					return try await (_endpoints, _containers, _stacks)
				}
			} catch {
				errorHandler?(error)
				throw error
			}
		}
		self.refreshTask = task

		return task
	}

	/// Refreshes endpoints, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<[Endpoint], Error>` of refresh.
	@discardableResult
	func refreshEndpoints(
		errorHandler: ErrorHandler? = nil,
		_debugInfo: String = ._debugInfo()
	) -> Task<[Endpoint], Error> {
		endpointsTask?.cancel()
		let task = Task<[Endpoint], Error> { @MainActor in
			defer { self.endpointsTask = nil }

			do {
				let endpoints = try await fetchEndpoints().sorted()
				self.setEndpoints(endpoints)
				return endpoints
			} catch {
				if error.isCancellationError { return self.endpoints }
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		self.endpointsTask = task
		return task
	}

	/// Refreshes containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<[Container], Error>` of refresh.
	@discardableResult
	func refreshContainers(
		errorHandler: ErrorHandler? = nil,
		_debugInfo: String = ._debugInfo()
	) -> Task<[Container], Error> {
		containersTask?.cancel()
		let task = Task<[Container], Error> { @MainActor in
			defer { self.containersTask = nil }

			do {
				let containers = try await fetchContainers().sorted()
				self.setContainers(containers)
				return containers
			} catch {
				if error.isCancellationError { return self.containers }
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		self.containersTask = task
		return task
	}

	/// Refreshes stacks, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<[Stack], Error>` of refresh.
	@discardableResult
	func refreshStacks(
		errorHandler: ErrorHandler? = nil,
		_debugInfo: String = ._debugInfo()
	) -> Task<[Stack], Error> {
		stacksTask?.cancel()
		let task = Task<[Stack], Error> { @MainActor in
			defer { self.stacksTask = nil }

			do {
				let stacks = try await fetchStacks().sorted()
				self.setStacks(stacks)
				return stacks
			} catch {
				if error.isCancellationError { return self.stacks }
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		self.stacksTask = task
		return task
	}
}

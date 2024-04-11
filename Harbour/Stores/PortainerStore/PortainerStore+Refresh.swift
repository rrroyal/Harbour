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
	) -> Task<([Endpoint], [Container]?), Error> {
		self.refreshTask?.cancel()

		let task = Task { @MainActor in
			defer { self.refreshTask = nil }

			do {
				let endpointsTask = refreshEndpoints(errorHandler: errorHandler)
				let endpoints = try await endpointsTask.value

				let containers: [Container]?
				if selectedEndpoint != nil {
					let containersTask = refreshContainers(errorHandler: errorHandler)
					containers = try await containersTask.value
				} else {
					containers = nil
				}

				return (endpoints, containers)
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
				let endpoints = try await fetchEndpoints()
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
				let containers = try await fetchContainers()
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
}

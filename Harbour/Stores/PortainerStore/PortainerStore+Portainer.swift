//
//  PortainerStore+Portainer.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - PortainerStore+Endpoints

extension PortainerStore {
	@Sendable
	func fetchEndpoints() async throws -> [Endpoint] {
		logger.info("Getting endpoints...")
		do {
			let endpoints = try await portainer.fetchEndpoints()
			logger.info("Got \(endpoints.count, privacy: .public) endpoint(s).")
			return endpoints
		} catch {
			logger.error("Failed to get endpoints: \(error, privacy: .public)")
			throw error
		}
	}
}

// MARK: - PortainerStore+Containers

extension PortainerStore {
	@Sendable
	func fetchContainers(filters: FetchFilters? = nil) async throws -> [Container] {
		logger.info("Getting containers, filters: \(String(describing: filters), privacy: .sensitive(mask: .hash))...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			let containers = try await portainer.fetchContainers(endpointID: selectedEndpoint.id, filters: filters)
			logger.info("Got \(containers.count, privacy: .public) container(s).")
			return containers
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public)")
			throw error
		}
	}

	/// Fetches all of the containers belonging to specified stack name.
	/// - Parameter stackName: Stack name
	/// - Returns: Array of containers
	@Sendable
	func fetchContainers(for stackName: String) async throws -> [Container] {
		logger.info("Getting containers for stack \"\(stackName, privacy: .sensitive(mask: .hash))\"...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			let containers = try await portainer.fetchContainers(endpointID: selectedEndpoint.id, stackName: stackName)
			logger.info("Got \(containers.count, privacy: .public) container(s).")
			return containers
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public)")
			throw error
		}
	}

	/// Fetches the details for the provided container ID.
	/// - Parameters:
	///   - containerID: ID of the inspected container
	///   - endpointID: ID of the endpoint
	/// - Returns: `ContainerDetails`
	@Sendable
	func fetchContainerDetails(_ containerID: Container.ID, endpointID: Endpoint.ID? = nil) async throws -> ContainerDetails {
		logger.info("Getting details for containerID: \"\(containerID, privacy: .private(mask: .hash))\"...")
		do {
			guard let endpointID = endpointID ?? selectedEndpoint?.id else {
				throw PortainerError.noSelectedEndpoint
			}
			let details = try await portainer.fetchContainerDetails(for: containerID, endpointID: endpointID)
			logger.info("Got details for containerID: \"\(containerID, privacy: .private(mask: .hash))\".")
			return details
		} catch {
			logger.error("Failed to get container details: \(error, privacy: .public)")
			throw error
		}
	}

	/// Fetches the logs for the provided container ID.
	/// - Parameters:
	///   - containerID: ID of the selected container
	///   - logsSince: `TimeInterval` for how old logs we want to fetch
	///   - lastEntriesAmount: Amount of last log lines
	///   - includeTimestamps: Include timestamps?
	/// - Returns: Logs of the container
	@Sendable
	func fetchContainerLogs(
		for containerID: Container.ID,
		since logsSince: TimeInterval = 0,
		tail logsTailAmount: LogsAmount? = 100,
		timestamps includeTimestamps: Bool? = false
	) async throws -> String {
		logger.info("Getting logs for containerID: \"\(containerID, privacy: .public)\"...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			// https://github.com/portainer/portainer/blob/8bb5129be039c3e606fb1dcc5b31e5f5022b5a7e/app/docker/helpers/logHelper/formatLogs.ts#L124

			let logs = try await portainer.fetchContainerLogs(
				for: containerID,
				endpointID: selectedEndpoint.id,
				stderr: true,
				stdout: true,
				since: logsSince,
				tail: logsTailAmount,
				includeTimestamps: includeTimestamps
			)
			// swiftlint:disable:next opening_brace
				.replacing(/^(.{8})/.anchorsMatchLineEndings(), with: "")

			logger.info("Got logs for containerID: \"\(containerID, privacy: .public)\".")

			return logs
		} catch {
			logger.error("Failed to get logs for containerID: \"\(containerID, privacy: .public)\": \(error, privacy: .public)")
			throw error
		}
	}

	/// Executes the provided action on selected container ID.
	/// - Parameters:
	///   - action: Action to execute
	///   - containerID: ID of the container we want to execute the action on.
	@Sendable
	func execute(_ action: ContainerAction, on containerID: Container.ID) async throws {
		logger.notice("Executing action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\"...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}
			try await portainer.executeContainerAction(action, containerID: containerID, endpointID: selectedEndpoint.id)

			Task { @MainActor in
				if let storedContainerIndex = containers.firstIndex(where: { $0.id == containerID }) {
					containers[storedContainerIndex].state = action.expectedState
				}
			}

			logger.notice("Executed action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\".")
		} catch {
			logger.error("Failed to execute action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\": \(error, privacy: .public)")
			throw error
		}
	}

	@Sendable @discardableResult
	func attachToContainer(containerID: Container.ID) throws -> AttachedContainer {
		logger.notice("Attaching to container with ID: \"\(containerID, privacy: .public)\"...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			let subject = try portainer.containerWebsocket(for: containerID, endpointID: selectedEndpoint.id)
			let container = containers.first { $0.id == containerID }
			guard let container else {
				throw PortainerError.containerNotFound(containerID)
			}

			logger.notice("Attached to container with ID: \"\(containerID, privacy: .public)\".")

			let attachedContainer = AttachedContainer(container: container, subject: subject)
			self.attachedContainer = attachedContainer
			return attachedContainer
		} catch {
			logger.error("Failed to attach to container with ID: \"\(containerID, privacy: .public)\": \(error, privacy: .public)")
			throw error
		}
	}
}

// MARK: - PortainerStore+Stacks

public extension PortainerStore {
	/// Fetches all of the stacks.
	/// - Returns: `[Stack]`
	@Sendable
	func fetchStacks() async throws -> [Stack] {
		logger.info("Fetching stacks...")
		do {
			let stacks = try await portainer.fetchStacks(endpointID: selectedEndpoint?.id)
			logger.info("Got \(stacks.count, privacy: .public) stack(s).")
			return stacks
		} catch {
			logger.error("Failed to fetch stacks: \(error, privacy: .public)")
			throw error
		}
	}

	@Sendable
	func fetchStack(id stackID: Stack.ID) async throws -> Stack {
		logger.info("Fetching stack for stackID: \(stackID)...")
		do {
			let details = try await portainer.fetchStackDetails(stackID: stackID)
			logger.info("Got stack for stackID: \(stackID)")
			return details
		} catch {
			logger.error("Failed to fetch stack for stackID: \(stackID): \(error, privacy: .public)")
			throw error
		}
	}

	/// Sets stack state (started/stopped) for provided stack ID.
	/// - Parameters:
	///   - stackID: Stack ID to start/stop
	///   - started: Should stack be started?
	/// - Returns: `Stack`
	@Sendable @discardableResult
	func setStackState(stackID: Stack.ID, started: Bool) async throws -> Stack? {
		defer {
			Task { @MainActor in
				loadingStacks.remove(stackID)
			}
		}

		logger.notice("\(started ? "Starting" : "Stopping", privacy: .public) stack with stackID: \(stackID)...")

		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			Task { @MainActor in
				loadingStacks.insert(stackID)
			}

			let newStack = try await portainer.setStackState(stackID: stackID, started: started, endpointID: selectedEndpoint.id)
			logger.notice("\(started ? "Started" : "Stopped", privacy: .public) stack with stackID: \(stackID)")

			Task {
				if let newStack, let stackIndex = stacks.firstIndex(where: { $0.id == stackID }) {
					Task { @MainActor in
						stacks[stackIndex] = newStack
					}
				}
			}

			return newStack
		} catch {
			logger.error("Failed to \(started ? "start" : "stop", privacy: .public) stack with stackID: \(stackID): \(error, privacy: .public)")
			throw error
		}
	}

	@Sendable
	func createStack(stackSettings: some StackDeploymentSettings) async throws -> Stack {
		logger.info("Creating a new stack...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}
			let stack = try await portainer.deployStack(endpointID: selectedEndpoint.id, settings: stackSettings)
			logger.info("Created a new stack, stackID: \(stack.id)")
			return stack
		} catch {
			logger.error("Failed to create a new stack: \(error, privacy: .public)")
			throw error
		}
	}

	@Sendable
	func fetchStackFile(stackID: Stack.ID) async throws -> String {
		logger.info("Fetching stack file for stackID: \(stackID)...")
		do {
			let stackFile = try await portainer.fetchStackFile(stackID: stackID)
			logger.info("Got stack file for stackID: \(stackID)")
			return stackFile
		} catch {
			logger.error("Failed to fetch stack file for stackID: \(stackID): \(error, privacy: .public)")
			throw error
		}
	}

	@Sendable
	func removeStack(stackID: Stack.ID) async throws {
		logger.info("Removing stack with ID: \(stackID)...")
		do {
			guard let selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}
			try await portainer.removeStack(stackID: stackID, endpointID: selectedEndpoint.id)
			logger.info("Removed stack with ID: \(stackID)")
		} catch {
			logger.error("Failed to remove stack with ID: \(stackID): \(error, privacy: .public)")
			throw error
		}
	}
}

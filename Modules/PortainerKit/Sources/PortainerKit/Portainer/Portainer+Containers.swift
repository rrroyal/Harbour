//
//  Portainer+Containers.swift
//  PortainerKit
//
//  Created by royal on 06/06/2023.
//

import Foundation

public extension Portainer {

	typealias ContainersFilters = [String: [String]]

	/// Returns a list of containers. For details on the format, see the inspect endpoint.
	/// - Parameter endpointID: Endpoint ID
	/// - Parameter filters: Query filters
	/// - Returns: `[Container]`
	@Sendable
	func fetchContainers(endpointID: Endpoint.ID, filters: ContainersFilters = [:]) async throws -> [Container] {
		var queryItems = [
			URLQueryItem(name: "all", value: "true")
		]
		if !filters.isEmpty {
			let filtersEncoded = try JSONEncoder().encode(filters)
			guard let queryItemString = String(data: filtersEncoded, encoding: .utf8) else {
				throw PortainerError.encodingFailed
			}
			let queryItem = URLQueryItem(name: "filters", value: queryItemString)
			queryItems.append(queryItem)
		}
		let request = try request(for: .containers(endpointID: endpointID), query: queryItems)
		return try await fetch(request: request)
	}

	/// Convenience function; fetches all of the containers belonging to the specified `stackName`.
	/// - Parameters:
	///   - endpointID: Endpoint ID
	///   - stackName: Stack name
	/// - Returns: `[Container]`
	@Sendable @inlinable
	func fetchContainers(endpointID: Endpoint.ID, stackName: String) async throws -> [Container] {
		let filters = [
			// This will probably break with Swarm projects, but it will be a problem for future me :)
			"label": ["\(Label.stack)=\(stackName)"]
		]
		return try await fetchContainers(endpointID: endpointID, filters: filters)
	}

	/// Return low-level information about a container.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: `ContainerDetails`
	@Sendable
	func inspectContainer(_ containerID: Container.ID, endpointID: Endpoint.ID) async throws -> ContainerDetails {
		let request = try request(for: .inspect(containerID: containerID, endpointID: endpointID))
		return try await fetch(request: request)
	}

	/// Executes an arbitary action on specified container.
	/// - Parameters:
	///   - action: Executed action
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	@Sendable
	func execute(_ action: ExecuteAction, containerID: Container.ID, endpointID: Endpoint.ID) async throws {
		var request = try request(for: .executeAction(containerID: containerID, endpointID: endpointID, action: action))
		request.httpMethod = "POST"
		request.httpBody = "{}".data(using: .utf8)

		let (data, response) = try await session.data(for: request)
		if let error = getError(from: data, response: response) {
			throw error
		}
	}

	/// Get stdout and stderr logs from a container.
	/// Note: This endpoint works only for containers with the json-file or journald logging driver.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	///   - since: Fetch logs since then
	///   - tail: Number of lines, counting from the end
	///   - timestamps: Display timestamps?
	/// - Returns: `String` logs
	@Sendable
	func fetchLogs(containerID: Container.ID,
				   endpointID: Endpoint.ID,
				   since logsSince: TimeInterval = 0,
				   tail lastEntriesAmount: Int = 100,
				   timestamps includeTimestamps: Bool = false) async throws -> String {
		let queryItems = [
			URLQueryItem(name: "since", value: "\(logsSince)"),
			URLQueryItem(name: "stderr", value: "true"),
			URLQueryItem(name: "stdout", value: "true"),
			URLQueryItem(name: "tail", value: "\(lastEntriesAmount)"),
			URLQueryItem(name: "timestamps", value: "\(includeTimestamps)")
		]
		let request = try request(for: .logs(containerID: containerID, endpointID: endpointID), query: queryItems)

		let (data, _) = try await session.data(for: request)
		guard let string = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else { throw PortainerError.decodingFailed }
		return string
	}

	/// Attach to a container to read its output or send it input. You can attach to the same container multiple times and you can reattach to containers that have been detached.
	/// Either the stream or logs parameter must be true for this endpoint to do anything.
	/// See the documentation for the docker attach command for more details.
	/// 
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: `WebSocketPassthroughSubject`
	@Sendable
	func attach(to containerID: Container.ID, endpointID: Endpoint.ID) throws -> WebSocketPassthroughSubject {
		guard let serverURL else {
			throw PortainerError.notSetup
		}

		guard let url: URL = {
			guard var components = URLComponents(url: serverURL.appendingPathComponent(RequestPath.attach.path), resolvingAgainstBaseURL: true) else { return nil }
			components.scheme = serverURL.scheme == "https" ? "wss" : "ws"
			components.queryItems = [
				URLQueryItem(name: "token", value: token),
				URLQueryItem(name: "endpointId", value: String(endpointID)),
				URLQueryItem(name: "id", value: containerID)
			]
			return components.url
		}() else { throw PortainerError.invalidURL }

		let task = session.webSocketTask(with: url)
		let passthroughSubject = WebSocketPassthroughSubject()

		@Sendable
		func setReceiveHandler() {
			wsQueue.async {
				task.receive { result in
					do {
						let message = WebSocketMessage(message: try result.get(), source: .server)
						passthroughSubject.send(message)
						setReceiveHandler()
					} catch {
						passthroughSubject.send(completion: .failure(error))
					}
				}
			}
		}

		setReceiveHandler()
		task.resume()

		return passthroughSubject
	}
}

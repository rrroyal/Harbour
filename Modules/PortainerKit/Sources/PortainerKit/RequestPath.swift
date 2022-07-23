//
//  RequestPath.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//

import Foundation

// MARK: - RequestPath

internal enum RequestPath {

	/// List all environments(endpoints) based on the current user authorizations.
	/// Will return all environments(endpoints) if using an administrator or team leader account.
	/// Otherwise it will only return authorized environments(endpoints).
	case endpoints

	/// Returns a list of containers. For details on the format, see the inspect endpoint.
	case containers(endpointID: Int)

	/// Return low-level information about a container.
	case inspect(containerID: String, endpointID: Int)

	/// Executes an arbitary action on specified container.
	case executeAction(containerID: String, endpointID: Int, action: ExecuteAction)

	/// Get stdout and stderr logs from a container.
	/// Note: This endpoint works only for containers with the json-file or journald logging driver.
	case logs(containerID: String, endpointID: Int)

	/// Attach to a container to read its output or send it input. You can attach to the same container multiple times and you can reattach to containers that have been detached.
	/// Either the stream or logs parameter must be true for this endpoint to do anything.
	/// See the documentation for the docker attach command for more details.
	case attach

}

// MARK: - RequestPath+path

extension RequestPath {
	var path: String {
		switch self {
			case .endpoints:
				return "/api/endpoints"
			case .containers(let endpointID):
				return "/api/endpoints/\(endpointID)/docker/containers/json"
			case .inspect(let containerID, let endpointID):
				return "/api/endpoints/\(endpointID)/docker/containers/\(containerID)/json"
			case .executeAction(let containerID, let endpointID, let action):
				return "/api/endpoints/\(endpointID)/docker/containers/\(containerID)/\(action.rawValue)"
			case .logs(let containerID, let endpointID):
				return "/api/endpoints/\(endpointID)/docker/containers/\(containerID)/logs"
			case .attach:
				return "/api/websocket/attach"
		}
	}
}

//
//  RequestPath.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// MARK: - RequestPath

internal enum RequestPath {

	/// List all environments(endpoints) based on the current user authorizations.
	/// Will return all environments(endpoints) if using an administrator or team leader account.
	/// Otherwise it will only return authorized environments(endpoints).
	case endpoints

	/// Returns a list of containers. For details on the format, see the inspect endpoint.
	case containers(endpointID: Endpoint.ID)

	/// Return low-level information about a container.
	case inspect(containerID: Container.ID, endpointID: Endpoint.ID)

	/// Executes an arbitary action on specified container.
	case executeAction(containerID: Container.ID, endpointID: Endpoint.ID, action: ExecuteAction)

	/// Get stdout and stderr logs from a container.
	/// Note: This endpoint works only for containers with the json-file or journald logging driver.
	case logs(containerID: Container.ID, endpointID: Endpoint.ID)

	/// Attach to a container to read its output or send it input. You can attach to the same container multiple times and you can reattach to containers that have been detached.
	/// Either the stream or logs parameter must be true for this endpoint to do anything.
	/// See the documentation for the docker attach command for more details.
	case attach

	/// List all stacks based on the current user authorizations.
	/// Will return all stacks if using an administrator account otherwise it will only return the list of stacks the user have access to.
	case stacks

	/// Retrieve details about a stack.
	case stack(stackID: Stack.ID)

	/// Starts a stopped Stack OR Stops a stopped Stack.
	case stackStatus(stackID: Stack.ID, started: Bool)

}

// MARK: - RequestPath+path

extension RequestPath {
	var path: String {
		switch self {
		case .endpoints:
			"/api/endpoints"
		case .containers(let endpointID):
			"/api/endpoints/\(endpointID)/docker/containers/json"
		case .inspect(let containerID, let endpointID):
			"/api/endpoints/\(endpointID)/docker/containers/\(containerID)/json"
		case .executeAction(let containerID, let endpointID, let action):
			"/api/endpoints/\(endpointID)/docker/containers/\(containerID)/\(action.rawValue)"
		case .logs(let containerID, let endpointID):
			"/api/endpoints/\(endpointID)/docker/containers/\(containerID)/logs"
		case .attach:
			"/api/websocket/attach"
		case .stacks:
			"/api/stacks"
		case .stack(let stackID):
			"/api/stacks/\(stackID)"
		case .stackStatus(let stackID, let started):
			"/api/stacks/\(stackID)/\(started ? "start" : "stop")"
		}
	}
}

//
//  PortainerKit+RequestPath.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//

import Foundation

@available(iOS 14, macOS 11, *)
internal extension PortainerKit {
	enum RequestPath {
		case login
		case endpoints
		case containers(endpointID: Int)
		case containerDetails(containerID: String, endpointID: Int)
		case executeAction(_ action: ExecuteAction, containerID: String, endpointID: Int)
		case logs(containerID: String, endpointID: Int, since: TimeInterval, tail: Int, timestamps: Bool)
		case attach

		var path: String {
			switch self {
				case .login:
					return "/api/auth"
				case .endpoints:
					return "/api/endpoints"
				case .containers(let endpointID):
					return "/api/endpoints/\(endpointID)/docker/containers/json?all=true"
				case .containerDetails(let containerID, let endpointID):
					return "/api/endpoints/\(endpointID)/docker/containers/\(containerID)/json"
				case .executeAction(let action, let containerID, let endpointID):
					return "/api/endpoints/\(endpointID)/docker/containers/\(containerID)/\(action.rawValue)"
				case .logs(let containerID, let endpointID, let since, let tail, let timestamps):
					return "/api/endpoints/\(endpointID)/docker/containers/\(containerID)/logs?since=\(since)&stderr=true&stdout=true&tail=\(tail)&timestamps=\(timestamps)"
				case .attach:
					return "/api/websocket/attach"
			}
		}
	}
}

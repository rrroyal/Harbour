//
//  PortainerKit+RequestPath.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//

import Foundation

@available(iOS 15, macOS 12, *)
internal extension PortainerKit {
	enum RequestPath {
		case login
		case endpoints
		case containers(endpointID: Int)
		case containerDetails(containerID: String, endpointID: Int)
		case executeAction(_ action: ExecuteAction, containerID: String, endpointID: Int)
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
				case .attach:
					return "/api/websocket/attach"					
			}
		}
	}
}

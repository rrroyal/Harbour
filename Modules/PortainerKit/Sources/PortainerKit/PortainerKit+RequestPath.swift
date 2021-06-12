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
		case containerDetails(endpointID: Int, containerID: String)
		case executeAction(_ action: ExecuteAction, endpointID: Int, containerID: String)
		
		var path: String {
			switch self {
				case .login:
					return "api/auth"
				case .endpoints:
					return "api/endpoints"
				case .containers(let endpointID):
					return "api/endpoints/\(endpointID)/docker/containers/json?all=true"
				case .containerDetails(let endpointID, let containerID):
					return "api/endpoints/\(endpointID)/docker/containers/\(containerID)/json"
				case .executeAction(let action, let endpointID, let containerID):
					return "api/endpoints/\(endpointID)/docker/containers/\(containerID)/\(action.rawValue)"
			}
		}
	}
}

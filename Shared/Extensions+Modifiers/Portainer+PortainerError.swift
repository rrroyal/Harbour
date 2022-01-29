//
//  Portainer+PortainerError.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import Foundation

extension Portainer {
	enum PortainerError: LocalizedError {
		case noServer
		case noAPI
		case noEndpoint
		case noToken
		case noCredentials
		
		var errorDescription: String {
			switch self {
				case .noServer: return Localization.PORTAINERERROR_NO_SERVER.localized
				case .noAPI: return Localization.PORTAINERERROR_NO_API.localized
				case .noEndpoint: return Localization.PORTAINERERROR_NO_ENDPOINT.localized
				case .noToken: return Localization.PORTAINERERROR_NO_TOKEN.localized
				case .noCredentials: return Localization.PORTAINERERROR_NO_CREDENTIALS.localized
			}
		}
		
		var recoverySuggestion: String? {
			switch self {
				case .noToken, .noCredentials:
					return "Try logging out and logging in back again."
				default:
					return nil
			}
		}
	}
}

//
//  Portainer+.swift
//  Harbour
//
//  Created by royal on 14/01/2022.
//

import Foundation
import PortainerKit

extension Portainer {
	enum PortainerError: LocalizedError {
		case noServerURL(URL?)
		case noAPI
		case noEndpoint
		case noToken
		case noCredentials

		public var errorDescription: String? {
			switch self {
				case .noServerURL: return Localization.Error.noServerURL
				case .noAPI: return Localization.Error.noAPI
				case .noEndpoint: return Localization.Error.noEndpoint
				case .noToken: return Localization.Error.noToken
				case .noCredentials: return Localization.Error.noCredentials
			}
		}

		public var recoverySuggestion: String? {
			switch self {
				case .noToken, .noCredentials:
					return Localization.ErrorRecoverySuggestion.relogin
				default:
					return nil
			}
		}
	}
}


#if DEBUG || WIDGET
private let containerData = """
{
	"Command": "COMMAND",
	"Created": 0,
	"HostConfig": {},
	"Id": "ID",
	"Image": "IMAGE",
	"ImageID": "IMAGEID",
	"Labels": {},
	"Mounts": [],
	"Names": ["/Containy"],
	"NetworkSettings": {},
	"Ports": [],
	"State": "running",
	"Status": "Up 1 day"
 }
"""

extension Portainer {
	struct PreviewData {
		static let container: PortainerKit.Container = try! JSONDecoder().decode(PortainerKit.Container.self, from: containerData.data(using: .utf8)!)
	}
}
#endif

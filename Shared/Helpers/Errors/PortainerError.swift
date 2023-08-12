//
//  PortainerError.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import Foundation

// MARK: - PortainerError

enum PortainerError: Error {
	/// `Portainer` isn't setup.
	case notSetup

	/// No server is stored.
	case noServer

	/// No endpoint is selected.
	case noSelectedEndpoint
}

// MARK: - PortainerError+LocalizedError

extension PortainerError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .notSetup:
			String(localized: "Error.Portainer.NotSetup")
		case .noServer:
			String(localized: "Error.Portainer.NoServer")
		case .noSelectedEndpoint:
			String(localized: "Error.Portainer.NoSelectedEndpoint")
		}
	}
}

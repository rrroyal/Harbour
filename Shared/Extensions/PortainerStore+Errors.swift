//
//  PortainerStore+Errors.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import Foundation

// MARK: - PortainerStore+PortainerError

extension PortainerStore {
	enum PortainerError: Error {
		/// `Portainer` isn't setup.
		case notSetup

		/// No server is stored.
		case noServer

		/// No endpoint is selected.
		case noSelectedEndpoint
	}
}

// MARK: - PortainerStore.PortainerError+LocalizedError

extension PortainerStore.PortainerError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .notSetup:
			return Localizable.Errors.Portainer.notSetup
		case .noServer:
			return Localizable.Errors.Portainer.noServer
		case .noSelectedEndpoint:
			return Localizable.Errors.Portainer.noSelectedEndpoint
		}
	}
}

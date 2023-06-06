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
	private typealias Localization = Localizable.Error.Portainer

	var errorDescription: String? {
		switch self {
		case .notSetup:
			Localization.notSetup
		case .noServer:
			Localization.noServer
		case .noSelectedEndpoint:
			Localization.noSelectedEndpoint
		}
	}
}

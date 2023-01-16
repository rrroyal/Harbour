//
//  PortainerStore+Errors.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import Foundation

extension PortainerStore {
	// TODO: Localize it
	enum PortainerError: Error {
		/// `Portainer` isn't setup.
		case notSetup

		/// No server is stored.
		case noServer

		/// No endpoint is selected.
		case noSelectedEndpoint
	}
}

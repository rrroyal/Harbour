//
//  PortainerStore+Errors.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import Foundation

extension PortainerStore {
	enum PortainerError: LocalizedError {
		/// `Portainer` variable isn't initialized.
		case noPortainer

		/// No endpoint is selected.
		case noSelectedEndpoint
	}
}

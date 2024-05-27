//
//  EnvironmentValues+Portainer.swift
//  Harbour
//
//  Created by royal on 22/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - portainerSelectedEndpoint

extension EnvironmentValues {
	var portainerSelectedEndpoint: Endpoint? {
		PortainerStore.shared.selectedEndpoint
	}
}

// MARK: - portainerServerURL

extension EnvironmentValues {
	var portainerServerURL: URL? {
		PortainerStore.shared.serverURL
	}
}

//
//  Portainer+System.swift
//  PortainerKit
//
//  Created by royal on 25/09/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

public extension Portainer {
	@Sendable
	func fetchSystemStatus() async throws -> SystemStatus {
		let request = try request(for: .systemStatus)
		return try await fetch(request: request)
	}
}

//
//  Portainer+Endpoints.swift
//  PortainerKit
//
//  Created by royal on 06/06/2023.
//

import Foundation

public extension Portainer {
	/// List all environments(endpoints) based on the current user authorizations.
	/// Will return all environments(endpoints) if using an administrator or team leader account.
	/// Otherwise it will only return authorized environments(endpoints).
	/// 
	/// - Returns: `[Endpoint]`
	@Sendable
	func fetchEndpoints() async throws -> [Endpoint] {
		let request = try request(for: .endpoints)
		return try await fetch(request: request)
	}
}

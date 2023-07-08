//
//  Portainer+Stacks.swift
//  PortainerKit
//
//  Created by royal on 06/06/2023.
//

import Foundation

public extension Portainer {
	/// Lists all stacks based on the current user authorizations.
	/// Will return all stacks if using an administrator account otherwise it will only return the list of stacks the user have access to.
	/// - Returns: `[Stack]`
	@Sendable
	func fetchStacks() async throws -> [Stack] {
		let request = try request(for: .stacks)
		return try await fetch(request: request)
	}

	@Sendable
	/// Starts a stopped Stack or stops a stopped Stack.
	/// - Parameters:
	///   - stackID: Stack identifier
	///   - started: Should stack be started?
	/// - Returns: Affected `Stack`
	func setStackStatus(stackID: Stack.ID, started: Bool) async throws -> Stack {
		var request = try request(for: .stackStatus(stackID: stackID, started: started))
		request.httpMethod = "POST"
		return try await fetch(request: request)
	}
}

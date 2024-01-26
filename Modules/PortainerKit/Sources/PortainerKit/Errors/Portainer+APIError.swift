//
//  Portainer+APIError.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

public extension Portainer {
	struct APIError: Codable {
		public let message: String?
		public let details: String?
	}
}

extension Portainer.APIError: LocalizedError {
	public var errorDescription: String? {
		message?.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	public var failureReason: String? {
		details?.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}

public extension Portainer.APIError {
	var isAuthorizationError: Bool {
		guard let message else { return false }
		return message.localizedCaseInsensitiveContains("invalid jwt token") ||
			message.localizedCaseInsensitiveContains("a valid authorisation token is missing") ||
			message.localizedCaseInsensitiveContains("unauthorized")
	}
}

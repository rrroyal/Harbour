//
//  PortainerKit+APIError.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//

import Foundation

@available(iOS 15, macOS 12, *)
public extension PortainerKit {
	enum APIError: Error, Comparable {
		case custom(_ reason: String)
		case responseCodeUnacceptable(_ code: Int)
		case unknownError
		
		case decodingFailed
		
		case invalidCredentials
		case invalidJWTToken
		case unauthorized
		
		case invalidPayload
		case invalidURL
		
		static func fromMessage(_ string: String?) -> Self {
			guard let reason = string?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return .unknownError }
			
			switch reason {
				case "invalid credentials":
					return .invalidCredentials
				case "invalid jwt token":
					return .invalidJWTToken
				case "unauthorized":
					return .unauthorized
				case "invalid request payload":
					return .invalidPayload
				default:
					return .custom(reason)
			}
		}
	}
}

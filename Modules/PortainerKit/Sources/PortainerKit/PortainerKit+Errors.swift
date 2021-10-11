//
//  PortainerKit+Errors.swift
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
		
		public var description: String {
			switch self {
				case .custom(let reason):					return reason
				case .responseCodeUnacceptable(let code):	return "Response unacceptable (\(code))"
				case .unknownError:							return "Unknown error"
				case .decodingFailed:						return "Decoding failed"
				case .invalidCredentials:					return "Invalid credentials"
				case .invalidJWTToken:						return "Invalid token"
				case .unauthorized:							return "Unauthorized"
				case .invalidPayload:						return "Invalid payload"
				case .invalidURL:							return "Invalid URL"
			}
		}
		
		internal static func fromMessage(_ string: String?) -> Self {
			guard let reason = string?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return .unknownError }
			
			switch reason {
				case "invalid credentials":		return .invalidCredentials
				case "invalid jwt token":		return .invalidJWTToken
				case "unauthorized":			return .unauthorized
				case "invalid request payload":	return .invalidPayload
				default:						return .custom(reason)
			}
		}
	}
	
	enum DateError: Error {
		case invalidDate(dateString: String)
	}
}

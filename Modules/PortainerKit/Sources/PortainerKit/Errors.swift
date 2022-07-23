//
//  Errors.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//

import Foundation

public enum APIError: LocalizedError, Comparable {
	case other(_ reason: String)
	case unknownError

	case responseCodeUnacceptable(_ code: Int)

	case encodingFailed
	case decodingFailed

	case invalidToken
	case unauthorized

	case invalidPayload
	case invalidURL

	public var errorDescription: String? {
		switch self {
			case .other(let reason):					return reason
			case .unknownError:							return "Unknown error"
			case .responseCodeUnacceptable(let code):	return "Response unacceptable (\(code))"
			case .encodingFailed:						return "Encoding failed"
			case .decodingFailed:						return "Decoding failed"
			case .invalidToken:							return "Invalid token"
			case .unauthorized:							return "Unauthorized"
			case .invalidPayload:						return "Invalid payload"
			case .invalidURL:							return "Invalid URL"
		}
	}

	public var recoverySuggestion: String? {
		switch self {
			case .invalidToken, .unauthorized:
				return "Try logging out and logging in back again."
			default:
				return nil
		}
	}

	internal static func fromMessage(_ string: String?) -> Self {
		guard let reason = string?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return .unknownError }

		switch reason {
			case "invalid jwt token", "a valid authorisation token is missing":
				return .invalidToken
			case "unauthorized":
				return .unauthorized
			case "invalid request payload":
				return .invalidPayload
			default:
				return .other(reason)
		}
	}

	internal static let errorMessageKey: String = "message"
}

public enum DateError: Error {
	case invalidDate(dateString: String)
}

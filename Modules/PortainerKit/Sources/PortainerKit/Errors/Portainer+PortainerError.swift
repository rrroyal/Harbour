//
//  Portainer+PortainerError.swift
//  PortainerKit
//
//  Created by royal on 01/10/2022.
//

import Foundation

public extension Portainer {
	enum PortainerError: Error {
		case notSetup

		case other(_ reason: String)
		case unknownError

		case responseCodeUnacceptable(_ code: Int)

		case encodingFailed
		case decodingFailed

		case invalidPayload
		case invalidURL

		internal static func fromAPIError(_ apiError: APIError) -> Self? {
			let reason = apiError.message.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

			switch reason {
			case "invalid request payload":
				return PortainerError.invalidPayload
			default:
				return nil
			}
		}
	}
}

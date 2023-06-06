//
//  APIError+LocalizedError.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//

import Foundation
import PortainerKit

extension Portainer.PortainerError: LocalizedError {
	private typealias Localization = Localizable.PortainerKit.Error.PortainerError

	public var errorDescription: String? {
		switch self {
		case .other(let reason):
			Localization.other(reason)
		case .unknownError:
			Localization.unknownError
		case .responseCodeUnacceptable(let code):
			Localization.responseCodeUnacceptable(code)
		case .encodingFailed:
			Localization.encodingFailed
		case .decodingFailed:
			Localization.decodingFailed
		case .invalidPayload:
			Localization.invalidPayload
		case .invalidURL:
			Localization.invalidURL
		case .notSetup:
			Localization.notSetup
		}
	}
}

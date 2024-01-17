//
//  PortainerError+LocalizedError.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Portainer.PortainerError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .other(let reason):
			String(localized: "PortainerKit.PortainerError.Other Reason:\(reason)")
		case .unknownError:
			String(localized: "PortainerKit.PortainerError.Unknown")
		case .responseCodeUnacceptable(let code):
			String(localized: "PortainerKit.PortainerError.ResponseCodeUnacceptable Code:\(code)")
		case .encodingFailed:
			String(localized: "PortainerKit.PortainerError.EncodingFailed")
		case .decodingFailed:
			String(localized: "PortainerKit.PortainerError.DecodingFailed")
		case .invalidPayload:
			String(localized: "PortainerKit.PortainerError.InvalidPayload")
		case .invalidURL:
			String(localized: "PortainerKit.PortainerError.InvalidURL")
		case .notSetup:
			String(localized: "PortainerKit.PortainerError.NotSetup")
		}
	}
}

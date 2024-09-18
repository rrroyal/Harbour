//
//  PortainerClient.ClientError+LocalizedError.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension PortainerClient.ClientError: @retroactive LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .notSetup:
			String(localized: "PortainerKit.ClientError.NotSetup")
		case .responseCodeUnacceptable(let code):
			String(localized: "PortainerKit.ClientError.ResponseCodeUnacceptable Code:\(code)")
		case .encodingFailed:
			String(localized: "PortainerKit.ClientError.EncodingFailed")
		}
	}
}

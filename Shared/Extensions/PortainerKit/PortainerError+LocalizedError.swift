//
//  PortainerError+LocalizedError.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension PortainerClient.Error: @retroactive LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .responseCodeUnacceptable(let code):
			String(localized: "PortainerKit.PortainerError.ResponseCodeUnacceptable Code:\(code)")
		case .notSetup:
			String(localized: "PortainerKit.PortainerError.NotSetup")
		}
	}
}

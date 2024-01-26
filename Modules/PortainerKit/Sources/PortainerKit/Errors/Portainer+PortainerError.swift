//
//  Portainer+PortainerError.swift
//  PortainerKit
//
//  Created by royal on 01/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
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
	}
}

//
//  HealthConfig.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public struct HealthConfig: Codable, Sendable, Equatable {
	enum CodingKeys: String, CodingKey {
		case test = "Test"
		case interval = "Interval"
		case timeout = "Timeout"
		case retries = "Retries"
		case startPeriod = "StartPeriod"
	}

	public let test: [String]
	public let interval: Int
	public let timeout: Int
	public let retries: Int
	public let startPeriod: Int
}

//
//  BindOptions.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public struct BindOptions: Equatable, Codable, Sendable {
	enum CodingKeys: String, CodingKey {
		case propagation = "Propagation"
	}

	public let propagation: Propagation?
}

public extension BindOptions {
	enum Propagation: String, Equatable, Codable, Sendable {
		case `private`
		case rprivate
		case shared
		case rshared
		case slave
		case rslave
	}
}

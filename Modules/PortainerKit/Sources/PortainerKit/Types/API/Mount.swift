//
//  Mount.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public struct Mount: Equatable, Codable, Sendable {
	enum CodingKeys: String, CodingKey {
		case target = "Target"
		case source = "Source"
		case type = "Type"
		case readOnly = "ReadOnly"
		case consistency = "Consistency"
		case bindOptions = "BindOptions"
	}

	public let target: String?
	public let source: String?
	public let type: MountType?
	public let readOnly: Bool?
	public let consistency: Consistency?
	public let bindOptions: BindOptions?
}

public extension Mount {
	enum Consistency: String, Equatable, Codable, Sendable {
		case `default`
		case consistent
		case cached
		case delegated
	}

	enum MountType: String, Equatable, Codable, Sendable {
		case bind
		case volume
		case tmpfs
	}
}

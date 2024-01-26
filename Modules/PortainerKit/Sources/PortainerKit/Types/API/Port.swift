//
//  Port.swift
//  PortianerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public struct Port: Equatable, Hashable, Codable, Sendable {
	enum CodingKeys: String, CodingKey {
		case ip = "IP"
		case privatePort = "PrivatePort"
		case publicPort = "PublicPort"
		case type = "Type"
	}

	public enum PortType: String, Hashable, Codable, Sendable {
		case tcp
		case udp
	}

	public let ip: String?
	public let privatePort: UInt16?
	public let publicPort: UInt16?
	public let type: PortType?
}

//
//  ContainerDetails.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// MARK: - ContainerDetails

public struct ContainerDetails: Identifiable, Codable, Sendable, Equatable {
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case created = "Created"
		case platform = "Platform"
		case path = "Path"
		case args = "Args"
		case status = "State"
		case image = "Image"
		case name = "Name"
		case restartCount = "RestartCount"
		case mountLabel = "MountLabel"
		case mounts = "Mounts"
		case config = "Config"
		case networkSettings = "NetworkSettings"
	}

	public let id: String
	public let created: Date
	public let platform: String
	public let path: String
	public let args: [String]
	public let status: ContainerStatus
	public let image: String
	public let name: String
	public let restartCount: Int
	public let mountLabel: String
	public let config: ContainerConfig?
	public let mounts: [MountPoint]
	public let networkSettings: NetworkSettings
}

// MARK: - ContainerDetails+NetworkSettings

public extension ContainerDetails {
	struct NetworkSettings: Codable, Sendable, Equatable {
		enum CodingKeys: String, CodingKey {
			case bridge = "Bridge"
			case gateway = "Gateway"
			case address = "Address"
			case ipPrefixLen = "IPPrefixLen"
			case macAddress = "MacAddress"
			case portMapping = "PortMapping"
			case ports = "Ports"
		}

		public let bridge: String
		public let gateway: String
		public let address: String?
		public let ipPrefixLen: Int
		public let macAddress: String
		public let portMapping: String?
		public let ports: Port
	}
}

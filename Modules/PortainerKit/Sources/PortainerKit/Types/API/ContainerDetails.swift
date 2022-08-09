//
//  ContainerDetails.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

import Foundation

public struct ContainerDetails: Identifiable, Decodable, Sendable {
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case created = "Created"
		case platform = "Platform"
		case path = "Path"
		case args = "Args"
		case state = "State"
		case image = "Image"
		case resolvConfPath = "ResolvConfPath"
		case hostnamePath = "HostnamePath"
		case hostsPath = "HostsPath"
		case logPath = "LogPath"
		case name = "Name"
		case restartCount = "RestartCount"
		case driver = "Driver"
		case mountLabel = "MountLabel"
		case processLabel = "ProcessLabel"
		case appArmorProfile = "AppArmorProfile"
		case sizeRW = "SizeRw"
		case sizeRootFS = "SizeRootFs"
		case mounts = "Mounts"
		case config = "Config"
		case networkSettings = "NetworkSettings"
	}

	public let id: String
	public let created: Date
	public let platform: String
	public let path: String
	public let args: [String]
	public let state: ContainerState
	public let image: String
	public let resolvConfPath: String
	public let hostnamePath: String
	public let hostsPath: String
	public let logPath: String
	// public let node: Any
	public let name: String
	public let restartCount: Int
	public let driver: String
	public let mountLabel: String
	public let processLabel: String
	public let appArmorProfile: String
	public let config: ContainerConfig?
	//	public let hostConfig: HostConfig?
	//	public let graphDriver: GraphDriver
	public let sizeRW: Int64?
	public let sizeRootFS: Int64?
	public let mounts: [MountPoint]
	public let networkSettings: NetworkSettings
}

public extension ContainerDetails {
	struct NetworkSettings: Decodable, Sendable {
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
//
//  ContainerDetails.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//

import Foundation

@available(iOS 15, macOS 12, *)
public extension PortainerKit {
	struct ContainerDetails: Identifiable, Decodable {
		public struct NetworkSettings: Decodable {
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
			case hostConfig = "HostConfig"
			case graphDriver = "GraphDriver"
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
		public let hostConfig: HostConfig?
		public let graphDriver: GraphDriver
		public let sizeRW: Int64?
		public let sizeRootFS: Int64?
		public let mounts: [MountPoint]
		public let networkSettings: NetworkSettings
		
		/* public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.id = try container.decode(String.self, forKey: .id)
			self.created = try container.decode(Date.self, forKey: .created)
			self.platform = try container.decode(String.self, forKey: .platform)
			self.path = try container.decode(String.self, forKey: .path)
			self.args = try container.decode([String].self, forKey: .args)
			self.state = try container.decode(ContainerState.self, forKey: .state)
			self.image = try container.decode(String.self, forKey: .image)
			self.resolvConfPath = try container.decode(String.self, forKey: .resolvConfPath)
			self.hostnamePath = try container.decode(String.self, forKey: .hostnamePath)
			self.hostsPath = try container.decode(String.self, forKey: .hostsPath)
			self.logPath = try container.decode(String.self, forKey: .logPath)
			self.name = try container.decode(String.self, forKey: .name)
			self.restartCount = try container.decode(Int.self, forKey: .restartCount)
			self.driver = try container.decode(String.self, forKey: .driver)
			self.mountLabel = try container.decode(String.self, forKey: .mountLabel)
			self.processLabel = try container.decode(String.self, forKey: .processLabel)
			self.appArmorProfile = try container.decode(String.self, forKey: .appArmorProfile)
			self.graphDriver = try container.decode(GraphDriver.self, forKey: .graphDriver)
			self.sizeRW = try container.decodeIfPresent(Int64.self, forKey: .sizeRW)
			self.sizeRootFS = try container.decodeIfPresent(Int64.self, forKey: .sizeRootFS)
			self.mounts = try container.decode([MountPoint].self, forKey: .mounts)
			self.networkSettings = try container.decode(NetworkSettings.self, forKey: .networkSettings)
			
			/* if let configData = try container.decodeIfPresent(Data.self, forKey: .config) {
				self.config = String(data: configData, encoding: .utf8)
			} else {
				self.config = nil
			}
			
			if let hostConfigData = try container.decodeIfPresent(Data.self, forKey: .hostConfig) {
				self.hostConfig = String(data: hostConfigData, encoding: .utf8)
			} else {
				self.hostConfig = nil
			} */
		} */
	}
}

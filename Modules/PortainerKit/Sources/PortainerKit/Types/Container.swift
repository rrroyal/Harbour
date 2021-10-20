//
//  Container.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine

@available(iOS 15, macOS 12, *)
public extension PortainerKit {
	class Container: Identifiable, Decodable, Equatable, ObservableObject {
		public struct NetworkSettings: Decodable {
			enum CodingKeys: String, CodingKey {
				case network = "Networks"
			}
			
			public let network: Network?
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case names = "Names"
			case image = "Image"
			case imageID = "ImageID"
			case command = "Command"
			case created = "Created"
			case ports = "Ports"
			case sizeRW = "SizeRw"
			case sizeRootFS = "SizeRootFs"
			case labels = "Labels"
			case state = "State"
			case status = "Status"
			case hostConfig = "HostConfig"
			case networkSettings = "NetworkSettings"
			case mounts = "Mounts"
		}

		public let id: String
		public let names: [String]?
		public let image: String
		public let imageID: String
		public let command: String?
		public let created: Date?
		public let ports: [Port]?
		public let sizeRW: Int64?
		public let sizeRootFS: Int64?
		public let labels: [String: String]?
		public var state: ContainerStatus?
		public var status: String?
		public let hostConfig: HostConfig?
		public let networkSettings: NetworkSettings?
		public let mounts: [Mount]?
		
		public var details: ContainerDetails? = nil
		
		/* public required init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.id = try container.decode(String.self, forKey: .id)
			self.names = try container.decodeIfPresent([String].self, forKey: .names)
			self.image = try container.decode(String.self, forKey: .image)
			self.imageID = try container.decode(String.self, forKey: .imageID)
			self.command = try container.decodeIfPresent(String.self, forKey: .command)
			self.created = try container.decodeIfPresent(Date.self, forKey: .created)
			self.ports = try container.decodeIfPresent([Port].self, forKey: .ports)
			self.sizeRW = try container.decodeIfPresent(Int64.self, forKey: .sizeRW)
			self.sizeRootFS = try container.decodeIfPresent(Int64.self, forKey: .sizeRootFS)
			self.labels = try container.decodeIfPresent([String :String].self, forKey: .labels)
			self.state = try container.decodeIfPresent(ContainerStatus.self, forKey: .state)
			self.status = try container.decodeIfPresent(String.self, forKey: .status)
			self.networkSettings = try container.decodeIfPresent(NetworkSettings.self, forKey: .networkSettings)
			self.mounts = try container.decodeIfPresent([Mount].self, forKey: .mounts)
			
			/* if let hostConfigData = try container.decodeIfPresent(Data.self, forKey: .hostConfig) {
				self.hostConfig = String(data: hostConfigData, encoding: .utf8)
			} else {
				self.hostConfig = nil
			} */
			
			let c = try decoder.singleValueContainer()
			c.decode([String: String?])
			
			let hostConfigData = try container.decodeIfPresent(Dictionary<String, String?>.self, forKey: .hostConfig)
			self.hostConfig = String(data: host, encoding: <#T##String.Encoding#>)
		} */

		public static func == (lhs: PortainerKit.Container, rhs: PortainerKit.Container) -> Bool {
			lhs.id == rhs.id &&
				lhs.state == rhs.state &&
				lhs.status == rhs.status &&
				lhs.names == rhs.names &&
				lhs.labels == rhs.labels
		}
		
		// TODO: Update other properties
		public func update(from details: PortainerKit.ContainerDetails) {
			self.details = details
			
			self.state = details.state.status
		}
	}
}

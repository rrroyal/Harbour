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
	final class Container: Identifiable, Decodable, ObservableObject {
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
		public let image: String?
		public let imageID: String
		public let command: String?
		public let created: Date?
		public let ports: [Port]?
		public let sizeRW: Int64?
		public let sizeRootFS: Int64?
		public let labels: [String: String]?
		@Published public var state: ContainerStatus?
		@Published public var status: String?
		public let hostConfig: HostConfig?
		public let networkSettings: NetworkSettings?
		public let mounts: [Mount]?
		
		public var details: ContainerDetails? = nil

		public init(id: String,
					names: [String]?,
					image: String?,
					imageID: String,
					command: String?,
					created: Date?,
					ports: [PortainerKit.Port]?,
					sizeRW: Int64?,
					sizeRootFS: Int64?,
					labels: [String : String]?,
					state: ContainerStatus?,
					status: String?,
					hostConfig: PortainerKit.HostConfig?,
					networkSettings: PortainerKit.Container.NetworkSettings?,
					mounts: [PortainerKit.Mount]?,
					details: PortainerKit.ContainerDetails? = nil
		) {
			self.id = id
			self.names = names
			self.image = image
			self.imageID = imageID
			self.command = command
			self.created = created
			self.ports = ports
			self.sizeRW = sizeRW
			self.sizeRootFS = sizeRootFS
			self.labels = labels
			self.state = state
			self.status = status
			self.hostConfig = hostConfig
			self.networkSettings = networkSettings
			self.mounts = mounts
			self.details = details
		}
	}
}

public extension PortainerKit.Container {
	static let stackLabelID = "com.docker.compose.project"

	var displayName: String? {
		guard let name: String = names?.first?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
		return name.starts(with: "/") ? String(name.dropFirst()) : name
	}
	
	var stack: String? {
		labels?.first(where: { $0.key == Self.stackLabelID })?.value
	}
}

extension PortainerKit.Container: Equatable, Hashable {
	
	// MARK: Equatable
	
	public static func == (lhs: PortainerKit.Container, rhs: PortainerKit.Container) -> Bool {
		lhs.id == rhs.id &&
		lhs.state == rhs.state &&
		lhs.names == rhs.names &&
		lhs.labels == rhs.labels
	}
	
	// MARK: Hashable
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

//
//  Container.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// MARK: - Container

public struct Container: Identifiable, Codable, Sendable {
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case names = "Names"
		case image = "Image"
		case imageID = "ImageID"
		case command = "Command"
		case created = "Created"
		case ports = "Ports"
		case labels = "Labels"
		case state = "State"
		case status = "Status"
		case networkSettings = "NetworkSettings"
		case mounts = "Mounts"
	}

	public let id: String
	public let names: [String]?
	public let image: String?
	public let imageID: String?
	public let command: String?
	public let created: Date?
	public let ports: [Port]?
	public let labels: [String: String]?
	public var state: ContainerState?
	public let status: String?
	public let networkSettings: NetworkSettings?
	public let mounts: [Mount]?

	public init(
		id: String,
		names: [String]? = nil,
		image: String? = nil,
		imageID: String? = nil,
		command: String? = nil,
		created: Date? = nil,
		ports: [Port]? = nil,
		labels: [String: String]? = nil,
		state: ContainerState? = nil,
		status: String? = nil,
		networkSettings: NetworkSettings? = nil,
		mounts: [Mount]? = nil
	) {
		self.id = id
		self.names = names
		self.image = image
		self.imageID = imageID
		self.command = command
		self.created = created
		self.ports = ports
		self.labels = labels
		self.state = state
		self.status = status
		self.networkSettings = networkSettings
		self.mounts = mounts
	}

//	required public init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		self.id = try container.decode(String.self, forKey: .id)
//		self.names = try container.decodeIfPresent([String].self, forKey: .names)
//		self.image = try container.decodeIfPresent(String.self, forKey: .image)
//		self.imageID = try container.decodeIfPresent(String.self, forKey: .imageID)
//		self.command = try container.decodeIfPresent(String.self, forKey: .command)
//		self.created = try container.decodeIfPresent(Date.self, forKey: .created)
//		self.ports = try container.decodeIfPresent([Port].self, forKey: .ports)
//		self.labels = try container.decodeIfPresent([String : String].self, forKey: .labels)
//		self.state = try container.decodeIfPresent(ContainerState.self, forKey: .state)
//		self.status = try container.decodeIfPresent(String.self, forKey: .status)
//		self.networkSettings = try container.decodeIfPresent(Container.NetworkSettings.self, forKey: .networkSettings)
//		self.mounts = try container.decodeIfPresent([Mount].self, forKey: .mounts)
//	}
}

// MARK: - Container+NetworkSettings

public extension Container {
	struct NetworkSettings: Equatable, Codable, Sendable {
		enum CodingKeys: String, CodingKey {
			case network = "Networks"
		}

		public let network: Network?
	}
}

// MARK: - Container+Equatable

extension Container: Equatable {
	public static func == (lhs: Container, rhs: Container) -> Bool {
		lhs.id == rhs.id &&
		lhs.image == rhs.image &&
		lhs.imageID == rhs.imageID &&
		lhs.state == rhs.state &&
		lhs.status == rhs.status &&
		lhs.created == rhs.created &&
		lhs.names == rhs.names &&
		lhs.command == rhs.command &&
		lhs.labels == rhs.labels &&
		lhs.ports == rhs.ports &&
		lhs.mounts == rhs.mounts &&
		lhs.networkSettings == rhs.networkSettings
	}
}

// MARK: - Container+Hashable

extension Container: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(names)
		hasher.combine(image)
		hasher.combine(imageID)
		hasher.combine(command)
		hasher.combine(created)
//		hasher.combine(ports)
		hasher.combine(labels)
		hasher.combine(state)
		hasher.combine(status)
//		hasher.combine(networkSettings)
//		hasher.combine(mounts)
	}
}

//
//  Container.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

import Foundation

// MARK: - Container

public struct Container: Identifiable, Decodable, Sendable {
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

	public init(id: String,
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
				mounts: [Mount]? = nil) {
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
}

// MARK: - Container+NetworkSettings

public extension Container {
	struct NetworkSettings: Equatable, Decodable, Sendable {
		enum CodingKeys: String, CodingKey {
			case network = "Networks"
		}

		public let network: Network?
	}
}

// MARK: - Container+Equatable

extension Container: Equatable {
	public static func == (lhs: Container, rhs: Container) -> Bool {
		lhs.state == rhs.state &&
		lhs.status == rhs.status &&
		lhs.created == rhs.created &&
		lhs.names == rhs.names &&
		lhs.command == rhs.command &&
		lhs.id == rhs.id &&
		lhs.image == rhs.image &&
		lhs.imageID == rhs.imageID &&
		lhs.labels == rhs.labels &&
		lhs.ports == rhs.ports &&
		lhs.mounts == rhs.mounts &&
		lhs.networkSettings == rhs.networkSettings
	}
}

//
//  Container.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

import Foundation

// MARK: - Container

public struct Container: Identifiable, Decodable {
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
	public var state: ContainerStatus?
	public var status: String?
	//	public let hostConfig: HostConfig?
	public let networkSettings: NetworkSettings?
	public let mounts: [Mount]?
}

// MARK: - Container+NetworkSettings

public extension Container {
	struct NetworkSettings: Decodable {
		enum CodingKeys: String, CodingKey {
			case network = "Networks"
		}

		public let network: Network?
	}
}

// MARK: - Container+stack

public extension Container {
	private static let stackLabelID = "com.docker.compose.project"

	var stack: String? {
		labels?.first(where: { $0.key == Self.stackLabelID })?.value
	}
}

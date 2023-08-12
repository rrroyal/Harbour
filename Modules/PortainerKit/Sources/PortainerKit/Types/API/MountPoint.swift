//
//  MountPoint.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

public struct MountPoint: Decodable, Sendable, Equatable {
	enum CodingKeys: String, CodingKey {
		case type = "Type"
		case name = "Name"
		case source = "Source"
		case destination = "Destination"
		case driver = "Driver"
		case mode = "Mode"
		case rw = "RW"
		case propagation = "Propagation"
	}

	public let type: String
	public let name: String?
	public let source: String
	public let destination: String
	public let driver: String?
	public let mode: String
	public let rw: Bool
	public let propagation: String
}

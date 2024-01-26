//
//  Network.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public struct Network: Equatable, Codable, Sendable {
	enum CodingKeys: String, CodingKey {
		case links = "Links"
		case aliases = "Aliases"
		case networkID = "NetworkID"
		case endpointID = "EndpointID"
		case gateway = "Gateway"
		case ipAddress = "IPAddress"
		case ipPrefixLen = "IPPrefixLen"
		case ipv6Gateway = "IPv6Gateway"
		case globalIPv6Address = "GlobalIPv6Address"
		case globalIPv6PrefixLen = "GlobalIPv6PrefixLen"
		case macAddress = "MacAddress"
	}

	public let links: [String]?
	public let aliases: [String]?
	public let networkID: String?
	public let endpointID: String?
	public let gateway: String?
	public let ipAddress: String?
	public let ipPrefixLen: Int?
	public let ipv6Gateway: String?
	public let globalIPv6Address: String?
	public let globalIPv6PrefixLen: Int64?
	public let macAddress: String?
}

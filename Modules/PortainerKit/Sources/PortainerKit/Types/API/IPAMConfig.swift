//
//  IPAMConfig.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

public struct IPAMConfig: Decodable, Sendable {
	enum CodingKeys: String, CodingKey {
		case ipv4Address = "IPv4Address"
		case ipv6Address = "IPv6Address"
		case linkLocalIPs = "LinkLocalIPs"
	}

	public let ipv4Address: String?
	public let ipv6Address: String?
	public let linkLocalIPs: [String]?
}

//
//  Endpoint.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

// MARK: - Endpoint

public struct Endpoint: Identifiable, Equatable, Decodable, Sendable {
	enum CodingKeys: String, CodingKey {
		case authorizedTeams = "AuthorizedTeams"
		case authorizedUsers = "AuthorizedUsers"
		case edgeID = "EdgeID"
		case groupID = "GroupID"
		case id = "Id"
		case name = "Name"
		case publicURL = "PublicURL"
		case status = "Status"
		case tls = "TLS"
		case tagIDs = "TagIds"
		case tags = "Tags"
		case type = "Type"
		case url = "URL"
	}

	public let authorizedTeams: [Int]?
	public let authorizedUsers: [Int]?
	public let edgeID: String?
	public let groupID: String?
	public let id: Int
	public let name: String?
	public let publicURL: String?
	public let status: Status?
	public let tls: Bool?
	public let tagIDs: [Int]?
	public let tags: [String]?
	public let type: EndpointType?
	public let url: String?
}

// MARK: - Endpoint+Status

public extension Endpoint {
	enum Status: Int, Decodable, Sendable {
		case up = 1
		case down
	}
}

// MARK: - Endpoint+EndpointType

public extension Endpoint {
	enum EndpointType: Int, Decodable, Sendable {
		case unknown = -1
		case docker = 1
		case agent = 2
		case azure = 3
		case edgeAgent = 4
		case edgeAgentK8s = 7

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			let rawValue = try container.decode(EndpointType.RawValue.self)
			self = EndpointType(rawValue: rawValue) ?? EndpointType.unknown
		}
	}
}

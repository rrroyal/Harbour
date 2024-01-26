//
//  Endpoint.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

// MARK: - Endpoint

public struct Endpoint: Identifiable, Equatable, Codable, Sendable {
	public typealias Name = String

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
	public let name: Name?
	public let publicURL: String?
	public let status: Status?
	public let tls: Bool?
	public let tagIDs: [Int]?
	public let tags: [String]?
	public let type: EndpointType?
	public let url: String?

	public init(
		authorizedTeams: [Int]? = nil,
		authorizedUsers: [Int]? = nil,
		edgeID: String? = nil,
		groupID: String? = nil,
		id: Int,
		name: String? = nil,
		publicURL: String? = nil,
		status: Status? = nil,
		tls: Bool? = nil,
		tagIDs: [Int]? = nil,
		tags: [String]? = nil,
		type: EndpointType? = nil,
		url: String? = nil
	) {
		self.authorizedTeams = authorizedTeams
		self.authorizedUsers = authorizedUsers
		self.edgeID = edgeID
		self.groupID = groupID
		self.id = id
		self.name = name
		self.publicURL = publicURL
		self.status = status
		self.tls = tls
		self.tagIDs = tagIDs
		self.tags = tags
		self.type = type
		self.url = url
	}
}

// MARK: - Endpoint+Status

public extension Endpoint {
	enum Status: Int, Codable, Sendable {
		case up = 1
		case down
	}
}

// MARK: - Endpoint+EndpointType

public extension Endpoint {
	enum EndpointType: Int, Codable, Sendable {
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

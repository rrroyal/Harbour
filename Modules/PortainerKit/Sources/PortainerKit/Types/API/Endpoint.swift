//
//  Endpoint.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

public struct Endpoint: Identifiable, Decodable {
	enum CodingKeys: String, CodingKey {
		case authorizedTeams = "AuthorizedTeams"
		case authorizedUsers = "AuthorizedUsers"
		case edgeCheckinInterval = "EdgeCheckinInterval"
		case edgeID = "EdgeID"
		case edgeKey = "EdgeKey"
		case groupID = "GroupID"
		case id = "Id"
		case name = "Name"
		case publicURL = "PublicURL"
		case snapshots = "Snapshots"
		case status = "Status"
		case tls = "TLS"
		case tlsCACert = "TLSCACert"
		case tlsCert = "TLSCert"
		case tlsKey = "TLSKey"
		case tagIDs = "TagIds"
		case tags = "Tags"
		case type = "Type"
		case url = "URL"
	}

	public let authorizedTeams: [Int]?
	public let authorizedUsers: [Int]?
	//	public let azureCredentials: AzureCredentials?
	public let edgeCheckinInterval: Int?
	public let edgeID: String?
	public let edgeKey: String?
	//	public let extensions: [EndpointExtension]?
	public let groupID: String?
	public let id: Int
	//	public let kubernetes: KubernetesData?
	public let name: String?
	public let publicURL: String?
	public let snapshots: [DockerSnapshot]?
	public let status: Status?
	public let tls: Bool?
	public let tlsCACert: String?
	public let tlsCert: String?
	//	public let tlsConfig: TLSConfiguration?
	public let tlsKey: String?
	public let tagIDs: [Int]?
	public let tags: [String]?
	//	public let teamAccessPolicies: AccessPolicy?
	public let type: EndpointType?
	public let url: String?
	//	public let userAccessPolicies: AccessPolicy?
}

public extension Endpoint {
	enum Status: Int, Decodable, Sendable {
		case up = 1
		case down
	}

	enum EndpointType: Int, Decodable, Sendable {
		case docker = 1
		case agent = 2
		case azure = 3
		case edgeAgent = 4
		case edgeAgentK8s = 7
	}
}

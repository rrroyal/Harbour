//
//  Endpoint.swift
//  PortainerKit
//
//  Created by royal on 11/06/2021.
//

import Foundation

@available(iOS 14, macOS 11, *)
public extension PortainerKit {
	class Endpoint: Identifiable, Codable {
		enum CodingKeys: String, CodingKey {
			case authorizedTeams = "AuthorizedTeams"
			case authorizedUsers = "AuthorizedUsers"
			case azureCredentials = "AzureCredentials"
			case edgeCheckinInterval = "EdgeCheckinInterval"
			case edgeID = "EdgeID"
			case edgeKey = "EdgeKey"
			case extensions = "Extensions"
			case groupID = "GroupID"
			case id = "Id"
			case kubernetes = "Kubernetes"
			case name = "Name"
			case publicURL = "PublicURL"
			case snapshots = "Snapshots"
			case status = "Status"
			case tls = "TLS"
			case tlsCACert = "TLSCACert"
			case tlsCert = "TLSCert"
			case tlsConfig = "TLSConfig"
			case tlsKey = "TLSKey"
			case tagIDs = "TagIds"
			case tags = "Tags"
			case teamAccessPolicies = "TeamAccessPolicies"
			case type = "Type"
			case url = "URL"
			case userAccessPolicies = "UserAccessPolicies"
		}

		public let authorizedTeams: [Int]?
		public let authorizedUsers: [Int]?
		public let azureCredentials: AzureCredentials?
		public let edgeCheckinInterval: Int?
		public let edgeID: String?
		public let edgeKey: String?
		public let extensions: [EndpointExtension]?
		public let groupID: String?
		public let id: Int
		public let kubernetes: KubernetesData?
		public let name: String?
		public let publicURL: String?
		public let snapshots: [DockerSnapshot]?
		public let status: EndpointStatus?
		public let tls: Bool?
		public let tlsCACert: String?
		public let tlsCert: String?
		public let tlsConfig: TLSConfiguration?
		public let tlsKey: String?
		public let tagIDs: [Int]?
		public let tags: [String]?
		public let teamAccessPolicies: AccessPolicy?
		public let type: EndpointType?
		public let url: String?
		public let userAccessPolicies: AccessPolicy?
	}
}

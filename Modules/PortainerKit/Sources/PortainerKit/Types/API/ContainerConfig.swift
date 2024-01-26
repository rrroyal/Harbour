//
//  ContainerConfig.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public struct ContainerConfig: Codable, Sendable, Equatable {
	enum CodingKeys: String, CodingKey {
		case hostname = "Hostname"
		case domainName = "DomainName"
		case user = "User"
		case exposedPorts = "ExposedPorts"
		case tty = "Tty"
		case env = "Env"
		case cmd = "Cmd"
		case healthCheck = "HealthCheck"
		case argsEscaped = "ArgsEscaped"
		case image = "Image"
		case volumes = "Volumes"
		case workingDir = "WorkingDir"
		case entrypoint = "Entrypoint"
		case networkDisabled = "NetworkDisabled"
		case macAddress = "MacAddress"
		case labels = "Labels"
		case stopSignal = "StopSignal"
		case stopTimeout = "StopTimeout"
		case shell = "Shell"
	}

	public let hostname: String
	public let domainName: String?
	public let user: String
	public let exposedPorts: [String: [String: String]]?
	public let tty: Bool
	public let env: [String]
	public let cmd: [String]?
	public let healthCheck: HealthConfig?
	public let argsEscaped: Bool?
	public let image: String
	public let volumes: [String: [String: String]]?
	public let workingDir: String
	public let entrypoint: [String]?
	public let networkDisabled: Bool?
	public let macAddress: String?
	public let labels: [String: String]
	public let stopSignal: String?
	public let stopTimeout: Int?
	public let shell: [String]?
}

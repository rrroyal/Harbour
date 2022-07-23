//
//  DockerSnapshot.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

public struct DockerSnapshot: Decodable, Sendable {
	enum CodingKeys: String, CodingKey {
		case dockerVersion = "DockerVersion"
		case healthyContainerCount = "HealthyContainerCount"
		case imageCount = "ImageCount"
		case runningContainerCount = "RunningContainerCount"
		case serviceCount = "ServiceCount"
		case stackCount = "StackCount"
		case stoppedContainerCount = "StoppedContainerCount"
		case swarm = "Swarm"
		case time = "Time"
		case totalCPU = "TotalCPU"
		case totalMemory = "TotalMemory"
		case unhealthyContainerCount = "UnhealthyContainerCount"
		case volumeCount = "VolumeCount"
	}

	public let dockerVersion: String?
	public let healthyContainerCount: Int?
	public let imageCount: Int?
	public let runningContainerCount: Int?
	public let serviceCount: Int?
	public let stackCount: Int?
	public let stoppedContainerCount: Int?
	public let swarm: Bool?
	public let time: Int?
	public let totalCPU: Int?
	public let totalMemory: Int?
	public let unhealthyContainerCount: Int?
	public let volumeCount: Int?
}

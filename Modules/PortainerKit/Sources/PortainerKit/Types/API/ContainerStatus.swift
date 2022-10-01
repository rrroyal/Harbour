//
//  ContainerStatus.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

import Foundation

public struct ContainerStatus: Decodable, Sendable {
	enum CodingKeys: String, CodingKey {
		case state = "Status"
		case running = "Running"
		case paused = "Paused"
		case restarting = "Restarting"
		case oomKilled = "OOMKilled"
		case dead = "Dead"
		case pid = "Pid"
		case error = "Error"
		case startedAt = "StartedAt"
		case finishedAt = "FinishedAt"
	}

	public let state: ContainerState
	public let running: Bool
	public let paused: Bool
	public let restarting: Bool
	public let oomKilled: Bool
	public let dead: Bool
	public let pid: Int
	public let error: String
	public let startedAt: Date?
	public let finishedAt: Date?
}

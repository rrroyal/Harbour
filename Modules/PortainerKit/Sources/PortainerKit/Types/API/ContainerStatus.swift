//
//  ContainerStatus.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

public struct ContainerStatus: Codable, Sendable, Equatable {
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
	public let error: String?
	public let startedAt: Date?
	public let finishedAt: Date?

	public init(
		state: ContainerState,
		running: Bool,
		paused: Bool,
		restarting: Bool,
		oomKilled: Bool,
		dead: Bool,
		pid: Int,
		error: String?,
		startedAt: Date?,
		finishedAt: Date?
	) {
		self.state = state
		self.running = running
		self.paused = paused
		self.restarting = restarting
		self.oomKilled = oomKilled
		self.dead = dead
		self.pid = pid
		self.error = error
		self.startedAt = startedAt
		self.finishedAt = finishedAt
	}
}

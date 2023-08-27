//
//  ContainerState.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

public enum ContainerState: String, Codable, Sendable, Equatable {
	case created
	case running
	case paused
	case restarting
	case removing
	case exited
	case dead
}

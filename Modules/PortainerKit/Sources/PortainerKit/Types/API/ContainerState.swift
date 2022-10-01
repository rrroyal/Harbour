//
//  ContainerState.swift
//  PortainerKit
//
//  Created by royal on 17/07/2022.
//

public enum ContainerState: String, Decodable, Sendable {
	case created
	case running
	case paused
	case restarting
	case removing
	case exited
	case dead
}

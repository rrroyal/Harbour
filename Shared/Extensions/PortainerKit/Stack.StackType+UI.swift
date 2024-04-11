//
//  Stack.StackType+UI.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit

// MARK: - Stack.StackType+label

extension Stack.StackType {
	var title: String {
		switch self {
		case .swarm:			String(localized: "PortainerKit.Stack.StackType.Swarm")
		case .dockerCompose:	String(localized: "PortainerKit.Stack.StackType.DockerCompose")
		}
	}
}

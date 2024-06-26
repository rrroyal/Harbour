//
//  Stack.StackType+UI.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit

// MARK: - Stack.StackType+title

extension Stack.StackType {
	var title: String {
		switch self {
		case .swarm:			String(localized: "PortainerKit.Stack.StackType.Swarm")
		case .dockerCompose:	String(localized: "PortainerKit.Stack.StackType.DockerCompose")
		case .kubernetes:		String(localized: "PortainerKit.Stack.StackType.Kubernetes")
		}
	}
}

extension Stack.StackType? {
	var title: String {
		self?.title ?? String(localized: "PortainerKit.Stack.StackType.Unknown")
	}
}

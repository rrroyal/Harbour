//
//  ContainerActions+actionsForState.swift
//  Harbour
//
//  Created by royal on 16/07/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit

extension ContainerAction {
	static func actionsForState(_ state: Container.State?) -> [ContainerAction] {
		switch state {
		case .created:
			[.pause, .stop, .restart, .kill]
		case .running:
			[.pause, .stop, .restart, .kill]
		case .paused:
			[.unpause, .stop, .restart, .kill]
		case .restarting:
			[.pause, .stop, .kill]
		case .removing:
			[.kill]
		case .exited:
			[.start]
		case .dead:
			[.start]
		case .none:
			[.unpause, .start, .restart, .pause, .stop, .kill]
		}
	}
}

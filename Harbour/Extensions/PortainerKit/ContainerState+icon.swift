//
//  ContainerState+icon.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import PortainerKit

// MARK: - ContainerState+icon

extension ContainerState {
	var icon: String {
		switch self {
			case .created:		return "wake"
			case .running:		return "power"
			case .paused:		return "pause"
			case .restarting:	return "restart"
			case .removing:		return "trash"
			case .exited:		return "poweroff"
			case .dead:			return "xmark"
		}
	}
}

// MARK: - ContainerState?+icon

extension ContainerState? {
	var icon: String {
		if let self {
			return self.icon
		} else {
			return "questionmark"
		}
	}
}

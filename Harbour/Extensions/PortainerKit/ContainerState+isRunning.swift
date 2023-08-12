//
//  ContainerState+isRunning.swift
//  Harbour
//
//  Created by royal on 13/08/2023.
//

import PortainerKit

extension ContainerState {
	var isRunning: Bool {
		self == .created || self == .paused || self == .removing || self == .restarting || self == .running
	}
}

extension ContainerState? {
	var isRunning: Bool {
		guard let self else { return false }
		return self.isRunning
	}
}

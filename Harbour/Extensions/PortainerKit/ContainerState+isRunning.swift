//
//  ContainerState+isRunning.swift
//  Harbour
//
//  Created by royal on 13/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
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

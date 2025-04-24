//
//  Container.State+isRunning.swift
//  Harbour
//
//  Created by royal on 13/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit

extension Container.State {
	var isRunning: Bool {
		switch self {
		case .created, .running, .restarting, .removing:
			true
		case .paused, .exited, .dead:
			false
		}
	}
}

extension Container.State? {
	var isRunning: Bool {
		self?.isRunning ?? false
	}
}

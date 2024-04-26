//
//  ContainerAction+expectedState.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension ContainerAction {
	var expectedState: Container.State {
		switch self {
		case .start:	.running
		case .stop:		.exited
		case .restart:	.restarting
		case .kill:		.exited
		case .pause:	.paused
		case .unpause:	.running
		}
	}
}

//
//  ExecuteAction+expectedState.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import PortainerKit

extension ExecuteAction {
	var expectedState: ContainerState {
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

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
			case .start:	return .running
			case .stop:		return .exited
			case .restart:	return .restarting
			case .kill:		return .exited
			case .pause:	return .paused
			case .unpause:	return .running
		}
	}
}

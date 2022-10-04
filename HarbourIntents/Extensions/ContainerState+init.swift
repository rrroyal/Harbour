//
//  ContainerState+init.swift
//  HarbourIntents
//
//  Created by royal on 04/10/2022.
//

import Foundation
import PortainerKit

extension ContainerState {
	init?(intentContainerState: IntentContainerState) {
		switch intentContainerState {
			case .created:		self = .created
			case .running:		self = .running
			case .paused:		self = .paused
			case .restarting:	self = .restarting
			case .removing:		self = .removing
			case .exited:		self = .exited
			case .dead:			self = .dead
			case .unknown:		return nil
		}
	}
}

//
//  ContainerState+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerState+color

extension ContainerState {
	var color: Color {
		switch self {
		case .created:		.yellow
		case .running:		.green
		case .paused:		.orange
		case .restarting:	.blue
		case .removing:		.lightGray
		case .exited:		.darkGray
		case .dead:			.gray
		}
	}
}

extension ContainerState? {
	var color: Color {
		if let self {
			self.color
		} else {
			.systemGray
		}
	}
}

// MARK: - ContainerState+description

extension ContainerState {
	var description: String {
		self.rawValue
	}
}

extension ContainerState? {
	var description: String {
		if let self {
			return self.rawValue
		} else {
			return Localizable.PortainerKit.ContainerState.unknown
		}
	}
}

// MARK: - ContainerState+icon

extension ContainerState {
	var icon: String {
		switch self {
		case .created:		"wake"
		case .running:		"power"
		case .paused:		"pause"
		case .restarting:	"restart"
		case .removing:		"trash"
		case .exited:		"poweroff"
		case .dead:			"xmark"
		}
	}
}

extension ContainerState? {
	var icon: String {
		if let self {
			return self.icon
		} else {
			return "questionmark"
		}
	}
}

// MARK: - ContainerState+emoji

extension ContainerState {
	var emoji: String {
		switch self {
		case .dead:			Localizable.PortainerKit.ContainerState.Icon.dead
		case .created:		Localizable.PortainerKit.ContainerState.Icon.created
		case .exited:		Localizable.PortainerKit.ContainerState.Icon.exited
		case .paused:		Localizable.PortainerKit.ContainerState.Icon.paused
		case .removing:		Localizable.PortainerKit.ContainerState.Icon.removing
		case .restarting:	Localizable.PortainerKit.ContainerState.Icon.restarting
		case .running:		Localizable.PortainerKit.ContainerState.Icon.running
		}
	}
}

extension ContainerState? {
	var emoji: String {
		if let self {
			self.emoji
		} else {
			Localizable.PortainerKit.ContainerState.Icon.unknown
		}
	}
}

// MARK: - ContainerState+isContainerOn

extension ContainerState {
	var isContainerOn: Bool {
		self == .created || self == .removing || self == .restarting || self == .running
	}
}

extension ContainerState? {
	var isContainerOn: Bool {
		if let self {
			self.isContainerOn
		} else {
			false
		}
	}
}

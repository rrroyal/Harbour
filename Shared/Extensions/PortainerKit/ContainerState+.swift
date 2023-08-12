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
			return String(localized: "PortainerKit.ContainerState.Unknown")
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
		case .dead:			String(localized: "PortainerKit.ContainerState.Icon.Dead")
		case .created:		String(localized: "PortainerKit.ContainerState.Icon.Created")
		case .exited:		String(localized: "PortainerKit.ContainerState.Icon.Exited")
		case .paused:		String(localized: "PortainerKit.ContainerState.Icon.Paused")
		case .removing:		String(localized: "PortainerKit.ContainerState.Icon.Removing")
		case .restarting:	String(localized: "PortainerKit.ContainerState.Icon.Restarting")
		case .running:		String(localized: "PortainerKit.ContainerState.Icon.Running")
		}
	}
}

extension ContainerState? {
	var emoji: String {
		if let self {
			self.emoji
		} else {
			String(localized: "PortainerKit.ContainerState.Icon.Unknown")
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

//
//  ContainerState+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerState+color

extension ContainerState {
	var color: Color {
		switch self {
		case .created:		Color(uiColor: .systemYellow)
		case .running:		Color(uiColor: .systemGreen)
		case .paused:		Color(uiColor: .systemOrange)
		case .restarting:	Color(uiColor: .systemBlue)
		case .removing:		Color(uiColor: .lightGray)
		case .exited:		Color(uiColor: .darkGray)
		case .dead:			Color(uiColor: .gray)
		}
	}
}

extension ContainerState? {
	var color: Color {
		self?.color ?? Color(uiColor: .darkGray)
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
		self?.rawValue ?? String(localized: "PortainerKit.ContainerState.Unknown")
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
		self?.icon ?? "questionmark"
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
		self?.emoji ?? String(localized: "PortainerKit.ContainerState.Icon.Unknown")
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
		self?.isContainerOn ?? false
	}
}

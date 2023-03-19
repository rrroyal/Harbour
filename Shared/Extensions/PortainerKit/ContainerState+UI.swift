//
//  ContainerState+UI.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainerState+color

extension ContainerState {
	var color: Color {
		switch self {
			case .created:		return .yellow
			case .running:		return .green
			case .paused:		return .orange
			case .restarting:	return .blue
			case .removing:		return Color(uiColor: .lightGray)
			case .exited:		return Color(uiColor: .darkGray)
			case .dead:			return .gray
		}
	}
}

extension ContainerState? {
	var color: Color {
		if let self {
			return self.color
		} else {
			return Color(uiColor: .systemGray5)
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
			case .created:		return "wake"
			case .running:		return "power"
			case .paused:		return "pause"
			case .restarting:	return "restart"
			case .removing:		return "trash"
			case .exited:		return "poweroff"
			case .dead:			return "xmark"
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
			case .dead:			return "☠️"
			case .created:		return "🐣"
			case .exited:		return "🚪"
			case .paused:		return "⏸️"
			case .removing:		return "🗑️"
			case .restarting:	return "🔄"
			case .running:		return "🏃"
		}
	}
}

extension ContainerState? {
	var emoji: String {
		if let self {
			return self.emoji
		} else {
			return "😶‍🌫️"
		}
	}
}

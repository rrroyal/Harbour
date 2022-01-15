//
//  PortainerKit+.swift
//  Shared
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

extension PortainerKit.Container {	
	var displayName: String? {
		guard let name: String = names?.first?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
		return name.starts(with: "/") ? String(name.dropFirst()) : name
	}
	
	var stack: String? {
		if let label = labels?.first(where: { $0.key == "com.docker.compose.project" })?.value {
			return label
		}
		
		let split = displayName?.split(separator: "_") ?? []
		if split.count >= 2, let first = split.first {
			return String(first)
		}
		
		return nil
		// labels?.first(where: { $0.key == "com.docker.compose.project" })?.value
	}
	
	@MainActor
	func update(from inspection: Portainer.ContainerInspection) {
		if let general = inspection.general {
			self.status = general.status
		}
		self.details = inspection.details
		self.state = inspection.details.state.status
	}
}

extension PortainerKit.ExecuteAction {
	var color: Color {
		switch self {
			case .start:	return .green
			case .stop:		return Color(uiColor: .darkGray)
			case .restart:	return .blue
			case .kill:		return .red
			case .pause:	return .orange
			case .unpause:	return .green
		}
	}
	
	var icon: String {
		switch self {
			case .start:	return "play"
			case .stop:		return "stop"
			case .restart:	return "restart"
			case .kill:		return "bolt"
			case .pause:	return "pause"
			case .unpause:	return "wake"
		}
	}
	
	var label: String {
		switch self {
			case .start:	return "Start"
			case .stop:		return "Stop"
			case .restart:	return "Restart"
			case .kill:		return "Kill"
			case .pause:	return "Pause"
			case .unpause:	return "Resume"
		}
	}
}

extension PortainerKit.ContainerStatus {
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

extension Optional where Wrapped == PortainerKit.ContainerStatus {
	var color: Color {
		if let color = self?.color { return color }
		return Color(uiColor: .systemGray5)
	}
	
	var icon: String {
		if let icon = self?.icon { return icon }
		return "questionmark"
	}
}

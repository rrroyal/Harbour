//
//  PortainerKit+.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI
import PortainerKit

extension PortainerKit.Endpoint {
	var displayName: String { self.name ?? "\(self.id)" }
}

extension PortainerKit.Container {
	var displayName: String? {
		guard let name: String = self.names?.first?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
		if name.starts(with: "/") {
			return String(name.dropFirst())
		} else {
			return name
		}
	}
	
	var stateColor: Color {
		switch self.state {
			case .created:		return .yellow
			case .running:		return .green
			case .paused:		return .orange
			case .restarting:	return .blue
			case .removing:		return Color(uiColor: .lightGray)
			case .exited:		return Color(uiColor: .darkGray)
			case .dead:			return .gray
			case .none:			return .clear
		}
	}
	
	var stateSymbol: String {
		switch self.state {
			case .created:		return "wake"
			case .running:		return "power"
			case .paused:		return "pause"
			case .restarting:	return "restart"
			case .removing:		return "trash"
			case .exited:		return "poweroff"
			case .dead:			return "xmark"
			case .none:			return "questionmark"
		}
	}
}

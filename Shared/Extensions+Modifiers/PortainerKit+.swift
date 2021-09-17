//
//  PortainerKit+.swift
//  Shared
//
//  Created by unitears on 11/06/2021.
//

import PortainerKit
import SwiftUI

extension PortainerKit.Endpoint {
	var displayName: String { name ?? "\(id)" }
}

extension PortainerKit.Container {
	var displayName: String? {
		guard let name: String = names?.first?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
		return name.starts(with: "/") ? String(name.dropFirst()) : name
	}

	var stateColor: Color {
		switch state {
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
		switch state {
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

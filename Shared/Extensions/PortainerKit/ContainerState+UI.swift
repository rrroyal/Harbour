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

// MARK: - ContainerState?+color

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

// MARK: - ContainerState?+description

extension ContainerState? {
	var description: String {
		if let self {
			return self.rawValue
		} else {
			return Localizable.Generic.unknown
		}
	}
}

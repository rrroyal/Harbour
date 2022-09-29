//
//  ContainerStatus+color.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

extension ContainerStatus {
	var color: Color {
		switch self {
			case .created:
				return Color.yellow
			case .running:
				return Color.green
			case .paused:
				return Color.orange
			case .restarting:
				return Color.blue
			case .removing:
				return Color(uiColor: .systemGray)
			case .exited:
				return Color(uiColor: .systemGray4)
			case .dead:
				return Color(uiColor: .systemGray2)
		}
	}
}

extension ContainerStatus? {
	var color: Color {
		if let self {
			return self.color
		} else {
			return Color(uiColor: .systemGray5)
		}
	}
}

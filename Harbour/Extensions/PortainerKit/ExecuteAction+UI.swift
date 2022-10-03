//
//  ExecuteAction+.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import SwiftUI
import PortainerKit

// MARK: - ExecuteAction+label

extension ExecuteAction {
	var label: String {
		typealias Localization = Localizable.PortainerKit.ExecuteAction
		switch self {
			case .start:	return Localization.start
			case .stop:		return Localization.stop
			case .restart:	return Localization.restart
			case .kill:		return Localization.kill
			case .pause:	return Localization.pause
			case .unpause:	return Localization.unpause
		}
	}
}

// MARK: - ExecuteAction+icon

extension ExecuteAction {
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
}

// MARK: - ExecuteAction+color

extension ExecuteAction {
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
}

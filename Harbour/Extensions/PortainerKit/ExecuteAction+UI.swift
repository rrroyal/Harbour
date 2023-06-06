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
	private typealias Localization = Localizable.PortainerKit.ExecuteAction

	var label: String {
		switch self {
		case .start:	Localization.start
		case .stop:		Localization.stop
		case .restart:	Localization.restart
		case .kill:		Localization.kill
		case .pause:	Localization.pause
		case .unpause:	Localization.unpause
		}
	}
}

// MARK: - ExecuteAction+icon

extension ExecuteAction {
	var icon: String {
		switch self {
		case .start:	"play"
		case .stop:		"stop"
		case .restart:	"restart"
		case .kill:		"bolt"
		case .pause:	"pause"
		case .unpause:	"wake"
		}
	}
}

// MARK: - ExecuteAction+color

extension ExecuteAction {
	var color: Color {
		switch self {
		case .start:	.green
		case .stop:		Color(uiColor: .darkGray)
		case .restart:	.blue
		case .kill:		.red
		case .pause:	.orange
		case .unpause:	.green
		}
	}
}

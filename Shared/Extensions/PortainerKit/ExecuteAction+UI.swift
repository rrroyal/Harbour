//
//  ExecuteAction+.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import PortainerKit
import SwiftUI

// MARK: - ExecuteAction+label

extension ExecuteAction {
	var title: String {
		switch self {
		case .start:	String(localized: "PortainerKit.ExecuteAction.Start")
		case .stop:		String(localized: "PortainerKit.ExecuteAction.Stop")
		case .restart:	String(localized: "PortainerKit.ExecuteAction.Restart")
		case .kill:		String(localized: "PortainerKit.ExecuteAction.Kill")
		case .pause:	String(localized: "PortainerKit.ExecuteAction.Pause")
		case .unpause:	String(localized: "PortainerKit.ExecuteAction.Unpause")
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
		case .stop:		.darkGray
		case .restart:	.blue
		case .kill:		.red
		case .pause:	.orange
		case .unpause:	.green
		}
	}
}

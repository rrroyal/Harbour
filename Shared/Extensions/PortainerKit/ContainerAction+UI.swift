//
//  ContainerAction+.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit
import SwiftUI

// MARK: - ContainerAction+label

extension ContainerAction {
	var title: String {
		switch self {
		case .start:	String(localized: "PortainerKit.ContainerAction.Start")
		case .stop:		String(localized: "PortainerKit.ContainerAction.Stop")
		case .restart:	String(localized: "PortainerKit.ContainerAction.Restart")
		case .kill:		String(localized: "PortainerKit.ContainerAction.Kill")
		case .pause:	String(localized: "PortainerKit.ContainerAction.Pause")
		case .unpause:	String(localized: "PortainerKit.ContainerAction.Unpause")
		}
	}
}

// MARK: - ContainerAction+icon

extension ContainerAction {
	var icon: String {
		switch self {
		case .start:	SFSymbol.start
		case .stop:		SFSymbol.stop
		case .restart:	SFSymbol.restart
		case .kill:		"bolt"
		case .pause:	SFSymbol.pause
		case .unpause:	"wake"
		}
	}
}

// MARK: - ContainerAction+color

extension ContainerAction {
	var color: Color {
		switch self {
		case .start:	.green
		case .stop:		.primaryGray
		case .restart:	.blue
		case .kill:		.red
		case .pause:	.orange
		case .unpause:	.green
		}
	}
}

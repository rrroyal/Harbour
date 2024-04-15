//
//  Stack.Status+UI.swift
//  Harbour
//
//  Created by royal on 07/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - Stack.Status+label

extension Stack.Status {
	var title: String {
		switch self {
		case .active:	String(localized: "PortainerKit.Stack.Status.Active")
		case .inactive: String(localized: "PortainerKit.Stack.Status.Inactive")
		}
	}
}

extension Stack.Status? {
	var title: String {
		self?.title ?? String(localized: "PortainerKit.Stack.Status.Unknown")
	}
}

// MARK: - Stack.Status+color

extension Stack.Status {
	var color: Color {
		switch self {
		case .active:	.green
		case .inactive:	.red
		}
	}
}

extension Stack.Status? {
	var color: Color {
		self?.color ?? .gray
	}
}

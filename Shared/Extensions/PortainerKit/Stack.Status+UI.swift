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

// MARK: - Stack.Status+icon

extension Stack.Status {
	var icon: String {
		switch self {
		case .active:	SFSymbol.start
		case .inactive: SFSymbol.stop
		}
	}
}

extension Stack.Status? {
	var icon: String {
		self?.icon ?? SFSymbol.questionMark
	}
}

// MARK: - Stack.Status+color

extension Stack.Status {
	var color: Color {
		#if canImport(UIKit)
		switch self {
		case .active:	Color(uiColor: .systemGreen)
		case .inactive:	Color.secondary
		}
		#elseif canImport(AppKit)
		switch self {
		case .active:	Color(nsColor: .systemGreen)
		case .inactive:	Color.secondary
		}
		#endif
	}
}

extension Stack.Status? {
	var color: Color {
		self?.color ?? Color.primaryGray
	}
}

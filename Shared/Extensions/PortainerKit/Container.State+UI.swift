//
//  Container.State+UI.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - Container.State+color

extension Container.State {
	var color: Color {
		#if canImport(UIKit)
		switch self {
		case .created:		Color(uiColor: .systemYellow)
		case .running:		Color(uiColor: .systemGreen)
		case .paused:		Color(uiColor: .systemOrange)
		case .restarting:	Color(uiColor: .systemBlue)
		case .removing:		Color(uiColor: .lightGray)
		case .exited:		Color(uiColor: .darkGray)
		case .dead:			Color(uiColor: .gray)
		}
		#elseif canImport(AppKit)
		switch self {
		case .created:		Color(nsColor: .systemYellow)
		case .running:		Color(nsColor: .systemGreen)
		case .paused:		Color(nsColor: .systemOrange)
		case .restarting:	Color(nsColor: .systemBlue)
		case .removing:		Color(nsColor: .lightGray)
		case .exited:		Color(nsColor: .darkGray)
		case .dead:			Color(nsColor: .gray)
		}
		#endif
	}
}

extension Container.State? {
	var color: Color {
		self?.color ?? Color.gray
	}
}

// MARK: - Container.State+title

extension Container.State {
	var title: String {
		self.rawValue.localizedCapitalized
	}
}

extension Container.State? {
	var title: String {
		self?.title ?? String(localized: "PortainerKit.Container.State.Unknown")
	}
}

// MARK: - Container.State+icon

extension Container.State {
	var icon: String {
		switch self {
		case .created:		"wake"
		case .running:		"power"
		case .paused:		"pause"
		case .restarting:	"arrow.triangle.2.circlepath"
		case .removing:		"trash"
		case .exited:		"stop"
		case .dead:			"xmark"
		}
	}
}

extension Container.State? {
	var icon: String {
		self?.icon ?? SFSymbol.questionMark
	}
}

// MARK: - Container.State+emoji

extension Container.State {
	var emoji: String {
		switch self {
		case .created:		String(localized: "PortainerKit.Container.State.Icon.Created")
		case .running:		String(localized: "PortainerKit.Container.State.Icon.Running")
		case .paused:		String(localized: "PortainerKit.Container.State.Icon.Paused")
		case .restarting:	String(localized: "PortainerKit.Container.State.Icon.Restarting")
		case .removing:		String(localized: "PortainerKit.Container.State.Icon.Removing")
		case .exited:		String(localized: "PortainerKit.Container.State.Icon.Exited")
		case .dead:			String(localized: "PortainerKit.Container.State.Icon.Dead")
		}
	}
}

extension Container.State? {
	var emoji: String {
		self?.emoji ?? String(localized: "PortainerKit.Container.State.Icon.Unknown")
	}
}

// MARK: - Container.State+isContainerOn

extension Container.State {
	var isContainerOn: Bool {
		self == .created || self == .removing || self == .restarting || self == .running
	}
}

extension Container.State? {
	var isContainerOn: Bool {
		self?.isContainerOn ?? false
	}
}

//
//  ViewTab.swift
//  Harbour
//
//  Created by royal on 17/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - ViewTab

enum ViewTab: CaseIterable, Hashable {
	case containers
	case stacks
}

// MARK: - ViewTab+label

extension ViewTab {
	var label: String {
		switch self {
		case .containers:
			String(localized: "ViewTab.Containers")
		case .stacks:
			String(localized: "ViewTab.Stacks")
		}
	}
}

// MARK: - ViewTab+icon

extension ViewTab {
	var icon: String {
		switch self {
		case .containers:
			SFSymbol.container
		case .stacks:
			SFSymbol.stack
		}
	}
}

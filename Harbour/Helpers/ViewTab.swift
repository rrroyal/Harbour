//
//  ViewTab.swift
//  Harbour
//
//  Created by royal on 17/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

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
	var icon: Image {
		switch self {
		case .containers:
			Image(SFSymbol.Custom.container)
		case .stacks:
			Image(systemName: SFSymbol.stack)
		}
	}
}

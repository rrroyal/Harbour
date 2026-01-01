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

// MARK: - ViewTab+UI

extension ViewTab {
	var title: String {
		switch self {
		case .containers:
			String(localized: "ContainersView.Title")
		case .stacks:
			String(localized: "StacksView.Title")
		}
	}

	var icon: Image {
		switch self {
		case .containers:
			Image(SFSymbol.Custom.container)
		case .stacks:
			Image(systemName: SFSymbol.stack)
		}
	}
}

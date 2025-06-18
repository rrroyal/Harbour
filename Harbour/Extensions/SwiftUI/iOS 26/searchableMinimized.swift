//
//  Searchable.swift
//  Harbour
//
//  Created by royal on 16/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

private struct SearchableMinimizedViewModifier: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26, *) {
			content
				.searchToolbarBehavior(.minimize)
//				.toolbar {
//					ToolbarSpacer(.flexible, placement: .bottomBar)
//					DefaultToolbarItem(kind: .search, placement: .bottomBar)
//				}
		} else {
			content
		}
	}
}

extension View {
	@ViewBuilder
	func searchableMinimized() -> some View {
		self
			.modifier(SearchableMinimizedViewModifier())
	}
}

//
//  View+refreshable.swift
//  Harbour
//
//  Created by royal on 17/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - View+refreshable

extension View {
	@ViewBuilder
	func refreshable(binding: Binding<Bool>, action: @escaping () async -> Void) -> some View {
		self
			.modifier(ScrollViewRefreshableViewModifier(binding: binding, action: action))
	}
}

// MARK: - ScrollViewRefreshableViewModifier

private struct ScrollViewRefreshableViewModifier: ViewModifier {
	@Binding var binding: Bool
	var action: () async -> Void

	func body(content: Content) -> some View {
		content
			.refreshable {
				binding = true
				await action()
				binding = false
			}
	}
}

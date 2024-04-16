//
//  View+listRowAttentionFocus.swift
//  Harbour
//
//  Created by royal on 16/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - View+listRowAttentionFocus

extension View {
	@ViewBuilder
	func listRowAttentionFocus(isFocused: Binding<Bool>, background: Color = .secondaryGroupedBackground) -> some View {
		modifier(ListRowAttentionFocusViewModifier(isFocused: isFocused, background: background))
	}
}

// MARK: - ListRowAttentionFocusViewModifier

private struct ListRowAttentionFocusViewModifier: ViewModifier {
	@State private var isFocusedInternally = false

	@Binding var isFocused: Bool
	var background: Color

	private let blinkInterval: TimeInterval = 0.2

	func body(content: Content) -> some View {
		content
			.listRowBackground(
				background
					.overlay {
						Color.accentColor
							.opacity(isFocusedInternally ? 0.2 : 0)
							.animation(.easeInOut(duration: blinkInterval))
					}
			)
			.task(id: isFocused) {
				guard isFocused else { return }
				isFocused = false

				Task {
					await blink()
					await blink()
					isFocusedInternally = false
				}
			}
	}

	private func blink() async {
		try? await Task.sleep(for: .seconds(blinkInterval))
		isFocusedInternally.toggle()
		try? await Task.sleep(for: .seconds(blinkInterval))
		isFocusedInternally.toggle()
	}
}

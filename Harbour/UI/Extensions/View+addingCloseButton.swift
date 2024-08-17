//
//  View+addingCloseButton.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - View+addingCloseButton

extension View {
	@ViewBuilder
	func addingCloseButton(dismissAction: (() -> Void)? = nil) -> some View {
		self
			.modifier(AddingCloseButtonViewModifier(dismissAction: dismissAction))
	}
}

// MARK: - AddingCloseButtonViewModifier

private struct AddingCloseButtonViewModifier: ViewModifier {
	@Environment(\.dismiss) private var _dismiss
	var dismissAction: (() -> Void)?

	func body(content: Content) -> some View {
		content
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					#if os(iOS)
					CloseButton(style: .circleButton) {
						dismissAction?() ?? _dismiss()
					}
					#elseif os(macOS)
					CloseButton(style: .text) {
						dismissAction?() ?? _dismiss()
					}
					#endif
				}
			}
	}
}

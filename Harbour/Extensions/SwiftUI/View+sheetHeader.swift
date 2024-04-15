//
//  View+sheetHeader.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - View+sheetHeader

extension View {
	@ViewBuilder
	func sheetHeader(_ title: LocalizedStringKey, systemIcon: String? = nil, dismissAction: (() -> Void)? = nil) -> some View {
		self
			.modifier(WithSheetHeaderViewModifier(title: title, systemIcon: systemIcon, dismissAction: dismissAction))
	}
}

// MARK: - WithSheetHeaderViewModifier

private struct WithSheetHeaderViewModifier: ViewModifier {
	@Environment(\.dismiss) private var _dismiss

	var title: LocalizedStringKey
	var systemIcon: String?
	var dismissAction: (() -> Void)?

	func body(content: Content) -> some View {
		content
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				var leadingPlacement: ToolbarItemPlacement {
					#if os(iOS)
					.topBarLeading
					#else
					.primaryAction
					#endif
				}
				ToolbarItem(placement: leadingPlacement) {
					HStack {
						if let systemIcon {
							Image(systemName: systemIcon)
						}

						Text(title)
					}
					.font(.headline)
				}

				var trailingPlacement: ToolbarItemPlacement {
					#if os(iOS)
					.topBarTrailing
					#else
					.destructiveAction
					#endif
				}
				ToolbarItem(placement: trailingPlacement) {
					CloseButton(style: .circleButton) {
						dismissAction?() ?? _dismiss()
					}
				}
			}
	}
}

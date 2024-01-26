//
//  KeyValueListView.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - KeyValueListView

struct KeyValueListView: View {
	var data: [Entry]

	var headerFont: Font = .footnote
	var contentFont: Font = .body

	@ViewBuilder
	private var placeholderView: some View {
		if data.isEmpty {
			ContentUnavailableView("Generic.Empty", systemImage: "ellipsis")
				.allowsHitTesting(false)
				.transition(.opacity)
		}
	}

	var body: some View {
		Form {
			ForEach(data) { entry in
				Section {
					Text(entry.value)
						.font(contentFont)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						.textSelection(.enabled)
				} header: {
					Text(entry.key)
						.font(headerFont)
						.textCase(.none)
				}
			}
		}
		.formStyle(.grouped)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.scrollContentBackground(.hidden)
		.background {
			placeholderView
		}
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.overlay {

		}
		.animation(.easeInOut, value: data)
	}
}

// MARK: - KeyValueListView+Modifiers

extension KeyValueListView {
	func headerFont(_ font: Font) -> Self {
		var s = self
		s.headerFont = font
		return s
	}

	func contentFont(_ font: Font) -> Self {
		var s = self
		s.contentFont = font
		return s
	}
}

// MARK: - KeyValueListView+Entry

extension KeyValueListView {
	struct Entry: Hashable, Identifiable {
		var id: Int { hashValue }

		let key: String
		let value: String
	}
}

// MARK: - Previews

#Preview {
	KeyValueListView(data: [.init(key: "Key", value: "Value")])
}

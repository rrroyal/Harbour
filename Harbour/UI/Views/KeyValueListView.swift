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
	@State private var query: String = ""

	var data: [KeyValueEntry]

	var headerFontDesign: Font.Design?
	var contentFontDesign: Font.Design?

	@ViewBuilder
	private var placeholderView: some View {
		if data.isEmpty {
			ContentUnavailableView("Generic.Empty", systemImage: "ellipsis")
				.allowsHitTesting(false)
		}
	}

	private var dataFiltered: [KeyValueEntry] {
		guard !query.isReallyEmpty else { return data }
		return data
			.filter {
				$0.key.localizedCaseInsensitiveContains(query) || $0.value.localizedCaseInsensitiveContains(query)
			}
			.localizedSorted(by: \.key)
	}

	var body: some View {
		Form {
			ForEach(dataFiltered) { entry in
				NormalizedSection {
					Text(entry.value.isEmpty ? String(localized: "Generic.Empty") : entry.value)
						.fontDesign(contentFontDesign)
						.foregroundStyle(entry.value.isEmpty ? .secondary : .primary)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						.textSelection(.enabled)
				} header: {
					Text(entry.key)
						.fontDesign(headerFontDesign)
						.textCase(.none)
				}
			}
		}
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
		.scrollContentBackground(.hidden)
		#if os(iOS)
		.searchable(text: $query)	// this breaks layout on macos :(
		#endif
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background {
			placeholderView
		}
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.animation(.smooth, value: data)
	}
}

// MARK: - KeyValueListView+Modifiers

extension KeyValueListView {
	func headerFontDesign(_ fontDesign: Font.Design?) -> Self {
		var s = self
		s.headerFontDesign = fontDesign
		return s
	}

	func contentFontDesign(_ fontDesign: Font.Design?) -> Self {
		var s = self
		s.contentFontDesign = fontDesign
		return s
	}
}

// MARK: - Previews

#Preview {
	KeyValueListView(data: [.init(key: "Key", value: "Value")])
}

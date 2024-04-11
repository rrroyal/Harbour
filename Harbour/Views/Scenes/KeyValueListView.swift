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

	var data: [Entry]

	var headerFontDesign: Font.Design?
	var contentFontDesign: Font.Design?

	@ViewBuilder
	private var placeholderView: some View {
		if data.isEmpty {
			ContentUnavailableView("Generic.Empty", systemImage: "ellipsis")
				.allowsHitTesting(false)
				.transition(.opacity)
		}
	}

	private var dataFiltered: [Entry] {
		guard !query.isReallyEmpty else { return data }
		return data.filter {
			$0.key.localizedCaseInsensitiveContains(query) || $0.value.localizedCaseInsensitiveContains(query)
		}
	}

	var body: some View {
		Form {
			ForEach(dataFiltered) { entry in
				NormalizedSection {
					Text(entry.value)
						.fontDesign(contentFontDesign)
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
		.searchable(text: $query)
		.formStyle(.grouped)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.scrollContentBackground(.hidden)
		.background {
			placeholderView
		}
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.animation(.easeInOut, value: data)
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

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
	@State private var searchText: String = ""

	var data: [KeyValueEntry]

	var headerFontDesign: Font.Design?
	var contentFontDesign: Font.Design?

	private var dataFiltered: [KeyValueEntry] {
		guard !searchText.isReallyEmpty else {
			return data.localizedSorted(by: \.key)
		}

		return data
			.filter {
				$0.key.localizedCaseInsensitiveContains(searchText) || $0.value.localizedCaseInsensitiveContains(searchText)
			}
			.localizedSorted(by: \.key)
	}

	@ViewBuilder
	private var placeholderView: some View {
		if dataFiltered.isEmpty {
			if !searchText.isReallyEmpty {
				ContentUnavailableView.search(text: searchText)
			} else {
				ContentUnavailableView("Generic.Empty", systemImage: "ellipsis")
			}
		}
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
		.searchable(
			text: $searchText,
			placement: {
				#if os(iOS)
				.automatic
				#elseif os(macOS)
				.toolbar
				#endif
			}()
		)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background {
			placeholderView
		}
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.animation(.default, value: dataFiltered)
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

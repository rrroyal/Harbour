//
//  DebugView+UserDefaultsView.swift
//  Harbour
//
//  Created by royal on 12/09/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

// MARK: - DebugView+UserDefaultsView

extension DebugView {
	struct UserDefaultsView: View {
		@State private var searchText = ""

		private var values: [String: Any] {
			let allItems = (Preferences.userDefaults?.dictionaryRepresentation() ?? [:])
			if searchText.isReallyEmpty {
				return allItems
			} else {
				return allItems
					.filter {
						$0.key.localizedCaseInsensitiveContains(searchText) || String(describing: $0.value).localizedCaseInsensitiveContains(searchText)
					}
			}
		}

		var body: some View {
			Form {
				ForEach(values.localizedSorted(by: \.key), id: \.key) { key, value in
					LabeledContent {
						Text(String(describing: value))
//							.multilineTextAlignment(.trailing)
					} label: {
						Text(key)
					}
					.textSelection(.enabled)
					.font(.callout)
					.fontDesign(.monospaced)
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							Haptics.generateIfEnabled(.heavy)
							Preferences.userDefaults?.removeObject(forKey: key)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}

					}
				}
			}
			.searchable(text: $searchText)
			.searchableMinimized()
			.overlay {
				if values.isEmpty {
					ContentUnavailableView("DebugView.UserDefaultsView.Empty", systemImage: SFSymbol.xmark)
				}
			}
			.navigationTitle("DebugView.UserDefaultsView.Title")
			.animation(.default, value: values.count)
		}
	}
}

// MARK: - Previews

#Preview {
	DebugView.UserDefaultsView()
}

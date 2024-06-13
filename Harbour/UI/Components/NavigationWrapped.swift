//
//  NavigationWrapped.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - NavigationWrapped

struct NavigationWrapped<Content: View, PlaceholderContent: View>: View {
	@EnvironmentObject private var preferences: Preferences
	@Binding var navigationPath: NavigationPath
	@ViewBuilder var content: () -> Content
	@ViewBuilder var placeholderContent: () -> PlaceholderContent

	private var useColumns: Bool {
		#if os(iOS)
		guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
			return false
		}
		#endif
		return preferences.useColumns
	}

	var body: some View {
		if useColumns {
			NavigationSplit(
				path: $navigationPath,
				content: content,
				placeholderContent: placeholderContent
			)
		} else {
			NavigationStacked(
				path: $navigationPath,
				content: content
			)
		}
	}
}

// MARK: - NavigationWrapped+NavigationSplit

private extension NavigationWrapped {
	struct NavigationSplit: View {
		@Binding var path: NavigationPath
		@ViewBuilder var content: () -> Content
		@ViewBuilder var placeholderContent: () -> PlaceholderContent

		var body: some View {
			NavigationSplitView {
				content()
			} detail: {
				NavigationStack(path: $path) {
					placeholderContent()
				}
			}
		}
	}
}

// MARK: - NavigationWrapped+NavigationStack

private extension NavigationWrapped {
	struct NavigationStacked: View {
		@Binding var path: NavigationPath
		@ViewBuilder var content: () -> Content

		var body: some View {
			NavigationStack(path: $path) {
				content()
			}
		}
	}
}

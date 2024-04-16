//
//  NavigationWrapped.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

struct NavigationWrapped<Content: View, PlaceholderContent: View>: View {
	@Binding var navigationPath: NavigationPath
	let content: () -> Content
	let placeholderContent: () -> PlaceholderContent

	private var useColumns: Bool {
		#if os(iOS)
		guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
			return false
		}
		#endif
		return Preferences.shared.useColumns
	}

	@ViewBuilder
	private var viewSplit: some View {
		NavigationSplitView {
			content()
				.navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
		} detail: {
			NavigationStack(path: $navigationPath) {
				placeholderContent()
			}
		}
	}

	@ViewBuilder
	private var viewStack: some View {
		NavigationStack(path: $navigationPath) {
			content()
		}
	}

	var body: some View {
		if useColumns {
			viewSplit
		} else {
			viewStack
		}
	}
}

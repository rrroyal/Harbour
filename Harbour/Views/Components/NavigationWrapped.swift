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
	let useColumns: Bool
	let content: () -> Content
	let placeholderContent: () -> PlaceholderContent

	@ViewBuilder
	private var viewSplit: some View {
		NavigationSplitView {
			content()
				.navigationSplitViewColumnWidth(min: 240, ideal: 240, max: 460)
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

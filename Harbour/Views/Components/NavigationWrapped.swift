//
//  NavigationWrapped.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

struct NavigationWrapped<Content: View, PlaceholderContent: View>: View {
	@EnvironmentObject private var sceneDelegate: SceneDelegate
	let useColumns: Bool
	let content: () -> Content
	let placeholderContent: () -> PlaceholderContent

	@ViewBuilder
	private var viewSplit: some View {
		NavigationSplitView {
			content()
				.navigationSplitViewColumnWidth(min: 300, ideal: 400, max: .infinity)
		} detail: {
			NavigationStack(path: $sceneDelegate.navigationPath) {
				placeholderContent()
			}
		}
	}

	@ViewBuilder
	private var viewStack: some View {
		NavigationStack(path: $sceneDelegate.navigationPath) {
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

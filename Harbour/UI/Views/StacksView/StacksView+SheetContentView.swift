//
//  StacksView+SheetContentView.swift
//  Harbour
//
//  Created by royal on 24/07/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

extension StacksView {
	struct SheetContentView: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(PortainerStore.self) private var portainerStore

		let stack: Stack?

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate

			NavigationStack {
				CreateStackView(
					portainerStore: portainerStore,
					existingStack: stack,
					onStackCreation: { _ in
						portainerStore.refreshStacks()
						portainerStore.refreshContainers()
					}
				)
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.addingCloseButton()
			}
			#if os(macOS)
			.sheetMinimumFrame(width: 380, height: 400)
			#endif
		}
	}
}

#Preview {
	StacksView.SheetContentView(stack: nil)
}

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
		@EnvironmentObject private var portainerStore: PortainerStore
		@Environment(SceneDelegate.self) private var sceneDelegate

		let stack: Stack?

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate

			NavigationStack {
				CreateStackView(existingStack: stack, onEnvironmentEdit: { _ in
					guard !sceneDelegate.handledCreateSheetDetentUpdate else { return }
					sceneDelegate.activeCreateStackSheetDetent = .large
					sceneDelegate.handledCreateSheetDetentUpdate = true
				}, onStackFileSelection: { stackFileContent in
					guard !sceneDelegate.handledCreateSheetDetentUpdate else { return }

					if stackFileContent != nil {
						sceneDelegate.activeCreateStackSheetDetent = .large
					}

					sceneDelegate.handledCreateSheetDetentUpdate = true
				}, onStackCreation: { _ in
					portainerStore.refreshStacks()
					portainerStore.refreshContainers()
				})
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.addingCloseButton()
			}
			.presentationDetents([.medium, .large], selection: $sceneDelegate.activeCreateStackSheetDetent)
			.presentationDragIndicator(.hidden)
			.presentationContentInteraction(.resizes)
			#if os(macOS)
			.sheetMinimumFrame(width: 380, height: 400)
			#endif
		}
	}
}

#Preview {
	StacksView.SheetContentView(stack: nil)
}

//
//  StacksView+StacksList.swift
//  Harbour
//
//  Created by royal on 24/07/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

extension StacksView {
	struct StacksList: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(StacksView.ViewModel.self) private var viewModel
		@EnvironmentObject private var portainerStore: PortainerStore
		var stacks: [StacksView.StackItem]
		var filterByStackNameAction: (String) -> Void
		var setStackStateAction: (Stack, Bool) -> Void
		var removeStackAction: (Stack) -> Void

		var body: some View {
			List {
				ForEach(stacks) { stackItem in
					let containers = portainerStore.containers.filter { $0.stack == stackItem.name }

					Group {
						if let stack = stackItem.stack {
							NavigationLink(value: StackDetailsView.NavigationItem(stackID: stackItem.id, stackName: stackItem.name)) {
								StackCell(
									stackItem,
									containers: containers,
									filterAction: { filterByStackNameAction(stackItem.name) },
									setStackStateAction: { setStackStateAction(stack, $0) }
								)
							}
						} else {
							StackCell(
								stackItem,
								containers: containers,
								filterAction: { filterByStackNameAction(stackItem.name) },
								setStackStateAction: nil
							)
						}
					}
					#if os(macOS)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					.listRowSeparator(.hidden)
					#endif
					.confirmationDialog(
						"Generic.AreYouSure",
						isPresented: sceneDelegate.isRemoveStackAlertPresented,
						titleVisibility: .visible,
						presenting: sceneDelegate.stackToRemove
					) { stack in
						Button("Generic.Remove", role: .destructive) {
							Haptics.generateIfEnabled(.heavy)
							removeStackAction(stack)
						}
						.tint(.red)
					} message: { stack in
						Text("StacksView.RemoveStackAlert.Message StackName:\(stack.name)")
					}
				}
			}
			#if os(iOS)
			.listStyle(.insetGrouped)
			#elseif os(macOS)
			.listStyle(.inset)
			#endif
			.animation(.default, value: stacks)
		}
	}
}

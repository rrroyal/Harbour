//
//  ContainersView+ContainerNavigationCell.swift
//  Harbour
//
//  Created by royal on 16/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

extension ContainersView {
	struct ContainerNavigationCell<Content: View>: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(PortainerStore.self) private var portainerStore
		@Environment(\.errorHandler) private var errorHandler
		@Environment(\.presentIndicator) private var presentIndicator
		let container: Container
		@ViewBuilder var content: () -> Content

		private var navigationItem: ContainerDetailsView.NavigationItem {
			.init(
				id: container.id,
				displayName: container.displayName,
				endpointID: portainerStore.selectedEndpoint?.id
			)
		}

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate
			
			NavigationLink(value: navigationItem) {
				content()
					.contextMenu {
						ContainerContextMenu(
							container: container,
							onContainerAction: {
								portainerStore.refreshContainers(ids: [container.id])
							}
						)
					}
					.confirmationDialog(
						"Generic.AreYouSure",
						item: $sceneDelegate.containerToRemove,
						titleVisibility: .visible,
					) { container in
						Button("Generic.Remove", role: .destructive) {
							Haptics.generateIfEnabled(.heavy)
							sceneDelegate.removeContainer(container)
						}
						.tint(.red)
					} message: { container in
						Text("ContainersView.RemoveContainerAlert.Message ContainerName:\(container.displayName ?? container.id)")
					}
			}
			.tint(Color.primary)
			#if os(macOS)
			.buttonStyle(.plain)
			#endif
		}
	}
}

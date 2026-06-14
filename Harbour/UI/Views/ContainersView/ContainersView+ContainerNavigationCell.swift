//
//  ContainersView+ContainerNavigationCell.swift
//  Harbour
//
//  Created by royal on 16/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

extension ContainersView {
	struct ContainerNavigationCell<Content: View>: View {
		@Environment(PortainerStore.self) private var portainerStore
		var container: Container
		@ViewBuilder var content: () -> Content

		private var navigationItem: ContainerDetailsView.NavigationItem {
			.init(
				id: container.id,
				displayName: container.displayName,
				endpointID: portainerStore.selectedEndpoint?.id
			)
		}

		var body: some View {
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
			}
			.tint(Color.primary)
			#if os(macOS)
			.buttonStyle(.plain)
			#endif
		}
	}
}

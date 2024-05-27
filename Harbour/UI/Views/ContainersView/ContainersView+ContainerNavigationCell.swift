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
		@EnvironmentObject private var portainerStore: PortainerStore
		@Environment(ContainersView.ViewModel.self) private var viewModel
		@Environment(\.portainerServerURL) private var portainerServerURL: URL?
		@Environment(\.portainerSelectedEndpoint) private var portainerSelectedEndpoint: Endpoint?
		@Environment(\.parentShape) private var parentShape
		var container: Container
		var content: () -> Content

		private var navigationItem: ContainerDetailsView.NavigationItem {
			let containerID = container.id
			let displayName = container.displayName
			let endpointID = portainerSelectedEndpoint?.id
			return .init(id: containerID, displayName: displayName, endpointID: endpointID)
		}

		private var portainerDeeplink: URL? {
			PortainerDeeplink(baseURL: portainerServerURL)?.containerURL(containerID: container.id, endpointID: portainerSelectedEndpoint?.id)
		}

		var body: some View {
			NavigationLink(value: navigationItem) {
				content()
			}
			.tint(Color.primary)
			#if os(macOS)
			.buttonStyle(.plain)
			#endif
			.if(let: parentShape) {
				$0
					.clipShape($1)
					.contentShape($1)
					#if os(iOS)
					.contentShape(.contextMenuPreview, $1)
					#endif
			}
			.contextMenu {
				ContainerContextMenu(container: container) {
					portainerStore.refreshContainers(ids: [container.id])
				}
			}
//			.if(let: portainerDeeplink) {
//				$0.draggable($1)
//			}
		}
	}
}

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
		@Environment(\.portainerServerURL) private var portainerServerURL: URL?
		@Environment(\.portainerSelectedEndpoint) private var portainerSelectedEndpoint: Endpoint?
		@Environment(\.parentShape) private var parentShape
		var container: Container
		@ViewBuilder var content: () -> Content

		private var navigationItem: ContainerDetailsView.NavigationItem {
			.init(
				id: container.id,
				displayName: container.displayName,
				endpointID: portainerSelectedEndpoint?.id
			)
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
			.clipShape(parentShape ?? AnyShape(Rectangle()))
			.contentShape(parentShape ?? AnyShape(Rectangle()))
			#if os(iOS)
			.contentShape(.contextMenuPreview, parentShape ?? AnyShape(Rectangle()))
			#endif
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

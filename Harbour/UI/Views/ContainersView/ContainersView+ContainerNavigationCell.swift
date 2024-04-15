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
		@Environment(\.portainerServerURL) private var portainerServerURL: URL?
		@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?
		@Environment(\.parentShape) private var parentShape
		let container: Container
		let content: () -> Content

		private var navigationItem: ContainerDetailsView.NavigationItem {
			let containerID = container.id
			let displayName = container.displayName
			let endpointID = portainerSelectedEndpointID
			return .init(id: containerID, displayName: displayName, endpointID: endpointID)
		}

		private var portainerDeeplink: URL? {
			PortainerDeeplink(baseURL: portainerServerURL)?.containerURL(containerID: container.id, endpointID: portainerSelectedEndpointID)
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
					.contentShape($1)
					#if os(iOS)
					.contentShape(.contextMenuPreview, $1)
					#endif
					.contentShape(.dragPreview, $1)
					.contentShape(.interaction, $1)
			}
			.contextMenu {
				ContainerContextMenu(container: container)
			}
			.if(let: portainerDeeplink) {
				$0.draggable($1)
			}
		}
	}
}

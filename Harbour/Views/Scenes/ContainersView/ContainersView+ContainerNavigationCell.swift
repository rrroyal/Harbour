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
		let container: Container
		let content: () -> Content

		private var navigationItem: ContainerDetailsView.NavigationItem {
			let containerID = container.id
			let displayName = container.displayName
			let endpointID = portainerSelectedEndpointID
			return .init(id: containerID, displayName: displayName, endpointID: endpointID)
		}

		var body: some View {
			NavigationLink(value: navigationItem) {
				content()
			}
			.tint(Color.primary)
			.buttonStyle(.plain)
		}
	}
}

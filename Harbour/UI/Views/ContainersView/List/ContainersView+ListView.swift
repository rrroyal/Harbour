//
//  ContainersView.ListView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView+ListView

extension ContainersView {
	struct ListView: View {
		@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?
		@Environment(SceneDelegate.self) private var sceneDelegate

		private let cellSpacing: Double = 8

		let containers: [Container]

		var body: some View {
			LazyVStack(spacing: cellSpacing) {
				ForEach(containers) { container in
					ContainersView.ContainerNavigationCell(container: container) {
						ContainerCell(container: container)
							.equatable()
							.id("ContainerCell.\(container._persistentID)")
							.tag(container._persistentID)
					}
					.transition(.opacity)
					.environment(\.parentShape, AnyShape(ContainerCell.roundedRectangleBackground))
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ScrollView {
		ContainersView.ListView(containers: [.preview])
			.padding()
	}
	.background(Color.groupedBackground)
	.environment(SceneDelegate())
	.withEnvironment(appState: .shared, preferences: .shared, portainerStore: .shared)
}

//
//  ContainersListView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainersListView

struct ContainersListView: View {
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?
	@EnvironmentObject private var sceneDelegate: SceneDelegate

	private let cellSpacing: Double = 8

	let containers: [Container]

	var body: some View {
		LazyVStack(spacing: cellSpacing) {
			ForEach(containers) { container in
				ContainersView.ContainerNavigationCell(container: container) {
					ContainerCell(container: container)
						.equatable()
				}
				.transition(.opacity)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContainersListView(containers: [])
}

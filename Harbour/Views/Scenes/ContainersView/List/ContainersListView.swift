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
	private static let cellSpacing: Double = 8

	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?
	@EnvironmentObject private var sceneState: SceneState

	let containers: [Container]

	var body: some View {
		ScrollView {
			LazyVStack(spacing: Self.cellSpacing) {
				ForEach(containers) { container in
					ContainersView.ContainerNavigationCell(container: container) {
						ContainerCell(container: container)
					}
					.transition(.opacity)
				}
			}
			.padding(.horizontal)
		}
		.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
		.animation(.easeInOut, value: containers)
	}
}

// MARK: - Previews

struct ContainersListView_Previews: PreviewProvider {
	static var previews: some View {
		ContainersListView(containers: [])
	}
}

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
	private static let cellSpacing: Double = 12

	@EnvironmentObject var sceneState: SceneState

	let containers: [Container]

	var body: some View {
		LazyVStack(spacing: Self.cellSpacing) {
			ForEach(containers) { container in
				NavigationLink(value: ContainersView.ContainerNavigationItem(id: container.id, displayName: container.displayName)) {
					ContainerCell(container: container)
						.equatable()
						.contextMenu {
							ContainersView.ContainerContextMenu(container: container)
						}
						.tint(Color.primary)
						.transition(.opacity)
				}
			}
		}
		.padding(.horizontal)
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

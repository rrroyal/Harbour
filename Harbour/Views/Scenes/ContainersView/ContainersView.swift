//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import PortainerKit

struct ContainersView: View {
	@EnvironmentObject private var sceneDelegate: SceneDelegate
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.containersViewUseGrid) private var useGrid: Bool
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler: SceneDelegate.ErrorHandler?
//	@Binding var searchFilter: String
	let containers: [Container]

//	private var containers: [Container] {
//		portainerStore.containers.filtered(query: searchFilter)
//	}

	@ViewBuilder
	private var containersList: some View {
		if useGrid {
			ContainersGridView(containers: containers)
		} else {
			ContainersListView(containers: containers)
		}
	}

	var body: some View {
		containersList
			.navigationDestination(for: ContainersView.ContainerNavigationItem.self) { item in
				ContainerDetailsView(containerNavigationItem: item)
			}
			.transition(.opacity)
			.animation(.easeInOut, value: useGrid)
			.animation(.easeInOut, value: containers)
			.animation(.easeInOut, value: portainerStore.selectedEndpoint == nil)
			.animation(.easeInOut, value: portainerStore.containers.isEmpty)
	}
}

// MARK: - Previews

struct ContainersView_Previews: PreviewProvider {
	static var previews: some View {
		ContainersView(containers: [])
	}
}

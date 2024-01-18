//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView

struct ContainersView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.cvUseGrid) private var useGrid
	let containers: [Container]

	init(_ containers: [Container]) {
		self.containers = containers
	}

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
			.padding(.horizontal)
			.padding(.bottom)
			.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
				ContainerDetailsView(navigationItem: navigationItem)
					.equatable()
			}
			.transition(.opacity)
			.animation(.easeInOut, value: useGrid)
//			.animation(.easeInOut, value: containers)
//			.animation(.easeInOut, value: portainerStore.selectedEndpoint == nil)
//			.animation(.easeInOut, value: portainerStore.containers.isEmpty)
	}
}

// MARK: - Previews

#Preview {
	ContainersView([])
}

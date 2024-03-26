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

	var body: some View {
		Group {
			if useGrid {
				ContainersGridView(containers: containers)
			} else {
				ContainersListView(containers: containers)
			}
		}
		.padding(.horizontal)
		.padding(.bottom)
		.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
			ContainerDetailsView(navigationItem: navigationItem)
				.equatable()
		}
		.transition(.opacity)
		.animation(.easeInOut, value: useGrid)
		.animation(.easeInOut, value: containers)
	}
}

// MARK: - Previews

#Preview {
	ScrollView {
		ContainersView(containers: [.preview])
	}
	.background(Color.groupedBackground)
	.environment(\.cvUseGrid, true)
	.environment(SceneState())
	// swiftlint:disable:next force_try
	.withEnvironment(appState: .shared, preferences: .shared, portainerStore: .shared, modelContext: .init(try! .default()))
}

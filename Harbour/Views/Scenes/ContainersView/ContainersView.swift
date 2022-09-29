//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

struct ContainersView: View {
	@Environment(\.containersViewUseGrid) var useGrid: Bool
	@Environment(\.sceneErrorHandler) var sceneErrorHandler: SceneState.ErrorHandler?
	@EnvironmentObject var portainerStore: PortainerStore
	let isLoading: Bool

	@State private var searchFilter: String = ""
	@State private var refreshTask: Task<Void, Error>?

	@ViewBuilder
	private var emptyPlaceholder: some View {
		Group {
			if isLoading {
				Text(Localizable.ContainersView.loadingPlaceholder)
			} else if portainerStore.selectedEndpoint == nil {
				Text(Localizable.ContainersView.noSelectedEndpointPlaceholder)
			} else if portainerStore.endpoints.isEmpty {
				Text(Localizable.ContainersView.noEndpointsPlaceholder)
			} else if portainerStore.containers.isEmpty {
				Text(Localizable.ContainersView.noContainersPlaceholder)
			}
		}
		.foregroundStyle(.secondary)
		.transition(.opacity)
	}

	@ViewBuilder
	private var containersList: some View {
		if useGrid {
			ContainersGridView(containers: portainerStore.containers.filtered(query: searchFilter))
		} else {
			ContainersListView(containers: portainerStore.containers.filtered(query: searchFilter))
		}
	}

	@ViewBuilder
	private var placeholderBackground: some View {
		ZStack {
			Color(uiColor: .systemGroupedBackground)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.ignoresSafeArea()

			if portainerStore.containers.isEmpty {
				emptyPlaceholder
			}
		}
	}

	var body: some View {
		ScrollView {
			containersList
		}
		.refreshable(action: refresh)
		.searchable(text: $searchFilter)
		.background(placeholderBackground)
		.navigationDestination(for: ContainersView.ContainerNavigationItem.self) { item in
			ContainerDetailsView(item: item)
		}
		.transition(.opacity)
		.animation(.easeInOut, value: useGrid)
		.animation(.easeInOut, value: portainerStore.selectedEndpoint == nil)
		.animation(.easeInOut, value: portainerStore.containers.isEmpty)
	}
}

// MARK: - ContainersView+Actions

private extension ContainersView {
	@Sendable
	func refresh() async {
		refreshTask?.cancel()
		refreshTask = portainerStore.refreshContainers(errorHandler: sceneErrorHandler)
	}
}

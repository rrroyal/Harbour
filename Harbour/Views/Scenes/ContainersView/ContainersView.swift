//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

struct ContainersView: View {
	private typealias Localization = Localizable.ContainersView

	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var sceneState: SceneState
	@Environment(\.containersViewUseGrid) private var useGrid: Bool
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler: SceneState.ErrorHandler?

	@State private var searchFilter: String = ""
	@State private var refreshTask: Task<Void, Error>?

	@ViewBuilder
	private var emptyPlaceholder: some View {
		Group {
			if sceneState.isLoading {
				Text(Localization.loadingPlaceholder)
			} else if portainerStore.selectedEndpointID == nil {
				Text(Localization.noSelectedEndpointPlaceholder)
			} else if portainerStore.endpoints.isEmpty {
				Text(Localization.noEndpointsPlaceholder)
			} else if portainerStore.containers.isEmpty {
				Text(Localization.noContainersPlaceholder)
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
		containersList
			.refreshable(action: refresh)
			.searchable(text: $searchFilter)
			.scrollDismissesKeyboard(.interactively)
			.background(placeholderBackground)
			.navigationDestination(for: ContainersView.ContainerNavigationItem.self) { item in
				ContainerDetailsView(item: item)
			}
			.transition(.opacity)
			.animation(.easeInOut, value: useGrid)
			.animation(.easeInOut, value: portainerStore.selectedEndpointID == nil)
			.animation(.easeInOut, value: portainerStore.containers.isEmpty)
	}
}

// MARK: - ContainersView+Actions

private extension ContainersView {
	@Sendable
	func refresh() async {
		do {
			refreshTask?.cancel()
			refreshTask = portainerStore.refresh(errorHandler: sceneErrorHandler)
			try await refreshTask?.value
		} catch {
			sceneErrorHandler?(error, ._debugInfo())
		}
	}
}

// MARK: - Previews

struct ContainersView_Previews: PreviewProvider {
	static var previews: some View {
		ContainersView()
	}
}

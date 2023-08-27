//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView

/// View fetching and displaying details for associated container ID.
struct ContainerDetailsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.portainerServerURL) private var portainerServerURL: URL?
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?

	@State private var viewModel: ViewModel

	let navigationItem: ContainerNavigationItem

	init(navigationItem: ContainerNavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(navigationItem: navigationItem)
		self._viewModel = .init(wrappedValue: viewModel)
	}

	var body: some View {
		List {
			DetailsSection(container: viewModel.container, details: viewModel.containerDetails)
			SubviewsSection(
				container: viewModel.container,
				details: viewModel.containerDetails,
				navigationItem: navigationItem
			)
		}
		.background(viewModel.viewState.backgroundView)
		.navigationTitle(viewModel.navigationTitle)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				ToolbarMenu(isLoading: viewModel.viewState.isLoading,
							containerID: navigationItem.id,
							container: viewModel.container(for: navigationItem))
			}
		}
		.refreshable {
			await viewModel.getContainerDetails(navigationItem: navigationItem, errorHandler: errorHandler).value
		}
		.task(id: "\(navigationItem.endpointID ?? -1).\(navigationItem.id)") {
			await viewModel.getContainerDetails(navigationItem: navigationItem, errorHandler: errorHandler).value
		}
		.animation(.easeInOut, value: viewModel.containerDetails != nil)
		.animation(.easeInOut, value: viewModel.viewState)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, element: navigationItem) { navigationItem, userActivity in
			viewModel.createUserActivity(for: navigationItem, userActivity: userActivity, errorHandler: errorHandler)
		}
	}
}

// MARK: - ContainerDetailsView+ToolbarMenu

private extension ContainerDetailsView {
	struct ToolbarMenu: View {
		@Environment(\.portainerServerURL) private var portainerServerURL
		@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID
		let isLoading: Bool
		let containerID: Container.ID
		let container: Container?

		var body: some View {
			Menu {
				if isLoading {
					Text("Generic.Loading")
					Divider()
				}

				if let container {
					Label(container.state.description.localizedCapitalized, systemImage: container.state.icon)
					Divider()
					ContainerContextMenu(container: container)
				}

				if let portainerURL = PortainerURLScheme(address: portainerServerURL)?.containerURL(containerID: containerID, endpointID: portainerSelectedEndpointID) {
					Divider()
					ShareLink("Generic.SharePortainerURL", item: portainerURL)
				}
			} label: {
				Label("Generic.More", systemImage: SFSymbol.moreCircle)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerDetailsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
}

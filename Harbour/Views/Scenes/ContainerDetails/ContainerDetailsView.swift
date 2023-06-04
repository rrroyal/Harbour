//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit
import CommonFoundation

// MARK: - ContainerDetailsView

/// View fetching and displaying details for associated container ID.
struct ContainerDetailsView: View {
	private typealias Localization = Localizable.ContainerDetails

	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.portainerServerURL) private var portainerServerURL: URL?
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?

	@StateObject private var viewModel: ViewModel

	let navigationItem: ContainerNavigationItem

	private var navigationTitle: String {
		viewModel.containerDetails?.displayName ?? navigationItem.displayName ?? viewModel.container(for: navigationItem)?.displayName ?? navigationItem.id
	}

	init(navigationItem: ContainerNavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel()
		self._viewModel = .init(wrappedValue: viewModel)
	}

	var body: some View {
		List {
			DetailsSection(container: viewModel.container, details: viewModel.containerDetails)
			LogsSection(navigationItem: navigationItem)
		}
		.background(PlaceholderView(viewState: viewModel.viewState))
		.navigationTitle(navigationTitle)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				ToolbarMenu(isLoading: viewModel.isLoading,
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
		.animation(.easeInOut, value: viewModel.isLoading)
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
					Text(Localizable.Generic.loading)
					Divider()
				}

				if let container {
					Label(container.state.description.localizedCapitalized, systemImage: container.state.icon)
					Divider()
					ContainerContextMenu(container: container)
				}

				if let portainerURL = PortainerURLScheme(address: portainerServerURL)?.containerURL(containerID: containerID, endpointID: portainerSelectedEndpointID) {
					Divider()
					ShareLink(Localizable.Generic.sharePortainerURL, item: portainerURL)
				}
			} label: {
				Label(Localizable.Generic.more, systemImage: SFSymbol.moreCircle)
			}
		}
	}
}

// MARK: - Previews

struct ContainerDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		ContainerDetailsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
	}
}

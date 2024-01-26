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

// TODO: View doesn't update when subview details are active & is navigated from deeplink

// MARK: - ContainerDetailsView

/// View fetching and displaying details for associated container ID.
struct ContainerDetailsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.portainerServerURL) private var portainerServerURL: URL?
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?
	@State private var viewModel: ViewModel
	var navigationItem: NavigationItem

	private var navigationTitle: String {
		viewModel.container?.displayName ??
			viewModel.containerDetails?.displayName ??
			viewModel.container?.id ??
			viewModel.containerDetails?.id ??
			navigationItem.displayName ??
			navigationItem.id
	}

	init(navigationItem: NavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(navigationItem: navigationItem)
		self._viewModel = .init(wrappedValue: viewModel)
	}

	var body: some View {
		Form {
			DetailsSection(container: viewModel.container, details: viewModel.containerDetails)

			Section {
				NavigationLink(value: Subdestination.labels) {
					Label("ContainerDetailsView.Section.Labels", systemImage: "tag")
				}
				.disabled(viewModel.containerDetails?.config?.labels == nil)

				NavigationLink(value: Subdestination.environment) {
					Label("ContainerDetailsView.Section.Environment", systemImage: "list.bullet.rectangle")
				}
				.disabled(viewModel.containerDetails?.config?.env == nil)

				NavigationLink(value: Subdestination.ports) {
					Label("ContainerDetailsView.Section.Ports", systemImage: "externaldrive.connected.to.line.below")
				}
				.disabled(viewModel.container?.ports == nil)

				NavigationLink(value: Subdestination.mounts) {
					Label("ContainerDetailsView.Section.Mounts", systemImage: "externaldrive")
				}
				.disabled(viewModel.containerDetails?.mounts == nil)

				NavigationLink(value: Subdestination.logs) {
					Label("ContainerDetailsView.Section.Logs", systemImage: SFSymbol.logs)
				}
			}
		}
		.scrollContentBackground(.hidden)
		.formStyle(.grouped)
//		.background(viewModel.viewState.backgroundView)
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.navigationTitle(navigationTitle)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				ToolbarMenu(
					isLoading: viewModel.viewState.isLoading,
					containerID: navigationItem.id,
					container: viewModel.container(for: navigationItem)
				)
			}

			ToolbarItem(placement: .status) {
				DelayedView(isVisible: viewModel.viewState.isLoading) {
					ProgressView()
				}
			}
		}
		.refreshable {
			await viewModel.getContainerDetails(navigationItem: navigationItem, errorHandler: errorHandler).value
		}
		.task(id: "refresh.\(navigationItem.endpointID ?? -1).\(navigationItem.id)") {
			await viewModel.getContainerDetails(navigationItem: navigationItem, errorHandler: errorHandler).value
		}
		.transition(.opacity)
		.animation(.easeInOut, value: navigationItem)
		.animation(.easeInOut, value: viewModel.container?.id)
		.animation(.easeInOut, value: viewModel.containerDetails?.id)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, element: navigationItem) { navigationItem, userActivity in
			viewModel.createUserActivity(userActivity, navigationItem: navigationItem)
		}
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .labels:
				LabelsDetailsView(labels: viewModel.containerDetails?.config?.labels)
			case .environment:
				EnvironmentDetailsView(environment: viewModel.containerDetails?.config?.env)
			case .ports:
				PortsDetailsView(ports: viewModel.container?.ports)
			case .mounts:
				MountsDetailsView(mounts: viewModel.containerDetails?.mounts)
			case .logs:
				ContainerLogsView(navigationItem: navigationItem)
			}
		}

		.id("\(Self.self).\(self.id)")
	}
}

// MARK: - ContainerDetailsView+Identifiable

extension ContainerDetailsView: Identifiable {
	var id: String {
		"\(Self.self).\(navigationItem.id)"
	}
}

// MARK: - ContainerDetailsView+Equatable

extension ContainerDetailsView: Equatable {
	static func == (lhs: ContainerDetailsView, rhs: ContainerDetailsView) -> Bool {
		lhs.navigationItem == rhs.navigationItem && lhs.viewModel.container?.id == rhs.viewModel.container?.id
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
			} label: {
				Label("Generic.More", systemImage: SFSymbol.moreCircle)
					.labelStyle(.automatic)
			}
			.labelStyle(.titleAndIcon)
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerDetailsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
}

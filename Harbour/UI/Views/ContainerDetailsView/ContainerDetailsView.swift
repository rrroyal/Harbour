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
	@Environment(SceneState.self) private var sceneState
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.portainerServerURL) private var portainerServerURL: URL?
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?
	@State var viewModel: ViewModel

	private var navigationTitle: String {
		viewModel.container?.displayName ??
		viewModel.containerDetails?.displayName ??
		viewModel.container?.id ??
		viewModel.containerDetails?.id ??
		viewModel.navigationItem.displayName ??
		viewModel.navigationItem.id
	}

	init(navigationItem: NavigationItem) {
		let viewModel = ViewModel(navigationItem: navigationItem)
		self._viewModel = .init(wrappedValue: viewModel)
	}

	var body: some View {
		Form {
			DetailsSection(container: viewModel.container, details: viewModel.containerDetails)

			NormalizedSection {
				NavigationLink(value: Subdestination.labels) {
					Label("ContainerDetailsView.Section.Labels", systemImage: "tag")
				}
				.disabled(viewModel.containerDetails?.config?.labels == nil)

				NavigationLink(value: Subdestination.environment) {
					Label("ContainerDetailsView.Section.Environment", systemImage: SFSymbol.environment)
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
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
		.scrollContentBackground(.hidden)
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				ToolbarMenu(
					isLoading: viewModel.viewState.isLoading,
					containerID: viewModel.navigationItem.id,
					container: viewModel.container(for: viewModel.navigationItem)
				)
			}

			ToolbarItem(placement: .status) {
				DelayedView(isVisible: viewModel.viewState.showAdditionalLoadingView) {
					ProgressView()
				}
				.transition(.opacity)
			}
		}
		.refreshable {
			await viewModel.getContainerDetails(navigationItem: viewModel.navigationItem, errorHandler: errorHandler).value
		}
		.task {
			await viewModel.getContainerDetails(navigationItem: viewModel.navigationItem, errorHandler: errorHandler).value
		}
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.navigationItem)
		.animation(.easeInOut, value: viewModel.container)
		.animation(.easeInOut, value: viewModel.containerDetails)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, isActive: sceneState.activeTab == .containers) { userActivity in
			viewModel.createUserActivity(userActivity)
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
				ContainerLogsView(navigationItem: viewModel.navigationItem)
			}
		}
		.navigationTitle(navigationTitle)
		.id("\(Self.self).\(self.id)")
	}
}

// MARK: - ContainerDetailsView+Identifiable

extension ContainerDetailsView: Identifiable {
	var id: String {
		"\(Self.self).\(viewModel.navigationItem.id)"
	}
}

// MARK: - ContainerDetailsView+Equatable

extension ContainerDetailsView: Equatable {
	static func == (lhs: ContainerDetailsView, rhs: ContainerDetailsView) -> Bool {
		lhs.viewModel.navigationItem == rhs.viewModel.navigationItem && lhs.viewModel.container == rhs.viewModel.container
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

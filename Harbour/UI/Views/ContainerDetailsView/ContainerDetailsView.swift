//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView

/// View fetching and displaying details for associated container ID.
struct ContainerDetailsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
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
		.scrollContentBackground(.hidden)
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Menu {
					if viewModel.viewState.isLoading {
						Text("Generic.Loading")
						Divider()
					}

					if let container = viewModel.container {
						ContainerContextMenu(container: container) {
							viewModel.attemptContainerRemoval()
						}
					}
				} label: {
					Label("Generic.More", systemImage: SFSymbol.moreCircle)
						.labelStyle(.automatic)
				}
				.labelStyle(.titleAndIcon)
			}

//			ToolbarItem(placement: .status) {
//				DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//					ProgressView()
//				}
//				.transition(.opacity)
//			}
		}
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await viewModel.getContainerDetails(navigationItem: viewModel.navigationItem, errorHandler: errorHandler).value
		}
		.task {
			await viewModel.getContainerDetails(navigationItem: viewModel.navigationItem, errorHandler: errorHandler).value
		}
		.transition(.opacity)
		.animation(nil, value: viewModel.navigationItem)
		.animation(.easeInOut, value: viewModel.container)
		.animation(.easeInOut, value: viewModel.containerDetails)
		.animation(.easeInOut, value: viewModel.isStatusProgressViewVisible)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, isActive: sceneDelegate.activeTab == .containers) { userActivity in
			viewModel.createUserActivity(userActivity)
		}
		.confirmationDialog(
			"Generic.AreYouSure?",
			isPresented: $viewModel.isRemoveContainerAlertPresented,
			titleVisibility: .visible
		) {
			Button("Generic.Remove", role: .destructive) {
				Haptics.generateIfEnabled(.heavy)
				removeContainer(force: true)
			}

//			Button("ContainersView.RemoveContainerAlert.RemoveForce", role: .destructive) {
//				Haptics.generateIfEnabled(.heavy)
//				removeContainer(force: true)
//			}
		} message: {
			let containerName = viewModel.container?.displayName ?? navigationItem.displayName ?? viewModel.container?.id ?? navigationItem.id
			Text("ContainersView.RemoveContainerAlert.Message ContainerName:\(containerName)")
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
		.onChange(of: navigationItem) { _, newNavigationItem in
			viewModel.navigationItem = newNavigationItem
		}
		.navigationTitle(navigationTitle)
		.id(self.id)
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
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.navigationItem == rhs.navigationItem && lhs.viewModel.container == rhs.viewModel.container
	}
}

// MARK: - ContainerDetailsView+Actions

private extension ContainerDetailsView {
	func removeContainer(force: Bool) {
		Task {
			let containerName = viewModel.container?.displayName ?? navigationItem.displayName ?? viewModel.container?.id ?? navigationItem.id
			do {
				presentIndicator(.containerRemove(containerName, state: .loading))
				try await viewModel.removeContainer(force: force)
				dismiss()
				presentIndicator(.containerRemove(containerName, state: .success))
			} catch {
				presentIndicator(.containerRemove(containerName, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerDetailsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
}

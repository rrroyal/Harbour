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

	private var container: Container? {
		viewModel.container
	}

	private var containerDetails: ContainerDetails? {
		viewModel.containerDetails
	}

	init(navigationItem: NavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(navigationItem: navigationItem)
		self.viewModel = viewModel
	}

	@ViewBuilder
	private var statusSection: some View {
		let state = (container?._isStored ?? true) ? Container.State?.none : (container?.state ?? containerDetails?.state.state ?? Container.State?.none)
		let title = container?.status ?? state.description.localizedCapitalized

		NormalizedSection {
			LabeledWithIcon(title, icon: state.icon)
				.foregroundColor(state.color)
		} header: {
			Text("ContainerDetailsView.Section.State")
		}
		.animation(.smooth, value: state)
	}

	@ViewBuilder
	private var healthSection: some View {
		if let health = containerDetails?.state.health {
			let lastHealthCheck = health.log?.max { $0.start.compare($1.start) == .orderedAscending }

			NormalizedSection {
				if let healthStatus = health.status {
					LabeledContent {
						Text(healthStatus)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
					} label: {
						Text("ContainerDetailsView.Section.Health.Status")
					}
				}

				if health.failingStreak > 0 {
					LabeledContent("ContainerDetailsView.Section.Health.FailingStreak", value: health.failingStreak.description)
						.textSelection(.enabled)
				}

				if let lastHealthCheck, !lastHealthCheck.output.isReallyEmpty {
					Text(lastHealthCheck.output.trimmingCharacters(in: .whitespacesAndNewlines))
						.fontDesign(.monospaced)
						.textSelection(.enabled)
				}
			} header: {
				Text("ContainerDetailsView.Section.Health")
			} footer: {
				if let lastHealthCheckDate = lastHealthCheck?.end {
					Text(lastHealthCheckDate, format: .dateTime)
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
			}
		}
	}

	@ViewBuilder
	private var idSection: some View {
		if let id = container?.id ?? containerDetails?.id {
			NormalizedSection {
				Labeled(id)
					.fontDesign(.monospaced)
			} header: {
				Text("ContainerDetailsView.Section.ID")
			}
		}
	}

	@ViewBuilder
	private var createdAtSection: some View {
		if let createdAt = containerDetails?.created ?? container?.created {
			NormalizedSection {
				Labeled(createdAt.formatted(.dateTime))
			} header: {
				Text("ContainerDetailsView.Section.CreatedAt")
			}
		}
	}

	@ViewBuilder
	private var finishedAtSection: some View {
		if let finishedAt = containerDetails?.state.finishedAt, !(containerDetails?.state.running ?? false) {
			NormalizedSection {
				Labeled(finishedAt.formatted(.dateTime))
			} header: {
				Text("ContainerDetailsView.Section.FinishedAt")
			}
		}
	}

	@ViewBuilder
	private var imageSection: some View {
		if container?.image != nil || container?.imageID != nil {
			NormalizedSection {
				Group {
					if let image = container?.image {
						Labeled(image)
					}

					if let imageID = container?.imageID {
						Labeled(imageID)
					}
				}
				.fontDesign(.monospaced)
			} header: {
				Text("ContainerDetailsView.Section.Image")
			}
		}
	}

	@ViewBuilder
	private var commandSection: some View {
		if let command = containerDetails?.config?.cmd?.joined(separator: " ") {
			NormalizedSection {
				Labeled(command)
					.fontDesign(.monospaced)
			} header: {
				Text("ContainerDetailsView.Section.Cmd")
			}
		}
	}

	@ViewBuilder
	private var entryPointSection: some View {
		if let entrypoint = containerDetails?.config?.entrypoint?.joined(separator: " ") {
			NormalizedSection {
				Labeled(entrypoint)
					.fontDesign(.monospaced)
			} header: {
				Text("ContainerDetailsView.Section.Entrypoint")
			}
		}
	}

	// MARK: body

	var body: some View {
		Form {
			Group {
				statusSection
				healthSection
				idSection
				createdAtSection
				finishedAtSection
				imageSection
				commandSection
				entryPointSection
			}

			NormalizedSection {
				NavigationLink(value: Subdestination.environment) {
					Label("ContainerDetailsView.Section.Environment", systemImage: SFSymbol.environment)
				}
				.disabled(containerDetails?.config?.env == nil)

				NavigationLink(value: Subdestination.labels) {
					Label("ContainerDetailsView.Section.Labels", systemImage: "tag")
				}
				.disabled(containerDetails?.config?.labels == nil)

				NavigationLink(value: Subdestination.mounts) {
					Label("ContainerDetailsView.Section.Mounts", systemImage: "externaldrive")
				}
				.disabled(containerDetails?.mounts == nil)

				NavigationLink(value: Subdestination.network) {
					Label("ContainerDetailsView.Section.Network", systemImage: SFSymbol.network)
				}
				.disabled(
					(container?.ports?.isEmpty ?? true) && (containerDetails == nil)
				)

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

					if let container {
						ContainerContextMenu(container: container) {
							viewModel.refresh()
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
//			}
		}
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			do {
				try await viewModel.refresh().value
			} catch {
				errorHandler(error)
			}
		}
		.task {
			do {
				try await viewModel.refresh().value
			} catch {
				errorHandler(error)
			}
		}
		.animation(.smooth, value: container)
		.animation(.smooth, value: container?.state)
		.animation(.smooth, value: containerDetails)
		.animation(.smooth, value: containerDetails?.state.state)
		.animation(.smooth, value: viewModel.navigationItem)
		.animation(.smooth, value: viewModel.isStatusProgressViewVisible)
		.animation(nil, value: navigationItem)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, isActive: sceneDelegate.activeTab == .containers) { userActivity in
			viewModel.createUserActivity(userActivity)
		}
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .labels:
				LabelsDetailsView(labels: containerDetails?.config?.labels)
			case .environment:
				EnvironmentDetailsView(environment: containerDetails?.config?.env)
			case .network:
				NetworkDetailsView(
					ports: container?.ports,
					detailNetworkSettings: containerDetails?.networkSettings,
					exposedPorts: containerDetails?.config?.exposedPorts,
					portBindings: containerDetails?.hostConfig.portBindings
				)
			case .mounts:
				MountsDetailsView(mounts: containerDetails?.mounts)
			case .logs:
				ContainerLogsView(containerID: navigationItem.id)
			}
		}
		.onChange(of: navigationItem) { _, newNavigationItem in
			viewModel.viewState = .loading
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
		lhs.navigationItem == rhs.navigationItem
	}
}

// MARK: - Previews

#Preview {
	ContainerDetailsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
}

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
	@State private var viewModel: ViewModel

	var navigationItem: NavigationItem

	init(navigationItem: NavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(navigationItem: navigationItem)
		self.viewModel = viewModel
	}

	private var navigationTitle: String {
		viewModel.container?.displayName ??
		viewModel.containerDetails?.displayName ??
		viewModel.container?.id ??
		viewModel.containerDetails?.id ??
		navigationItem.displayName ??
		navigationItem.id
	}

	@ViewBuilder
	private var statusSection: some View {
		let state = (viewModel.container?._isStored ?? true) ? Container.State?.none : (viewModel.container?.state ?? viewModel.containerDetails?.state.state ?? Container.State?.none)
		let title = viewModel.container?.status ?? state.title

		NormalizedSection {
			if state == .none && !(viewModel.fetchTask?.isCancelled ?? true) {
				Label {
					Text("Generic.Loading")
				} icon: {
					ProgressView()
						#if os(macOS)
						.controlSize(.small)
						#endif
				}
				.foregroundStyle(.secondary)
			} else {
				LabeledWithIcon(title, icon: state.icon)
					.foregroundStyle(state.color)
			}
		} header: {
			Text("ContainerDetailsView.Section.State")
		}
		.animation(.default, value: state)
		.animation(.default, value: viewModel.fetchTask?.isCancelled)
	}

	@ViewBuilder
	private var healthSection: some View {
		if let health = viewModel.containerDetails?.state.health {
			let lastHealthCheck = health.log?.max { $0.start.compare($1.start) == .orderedAscending }

			NormalizedSection {
				if let healthStatus = health.status {
					LabeledContent {
						Text(healthStatus)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					} label: {
						Text("ContainerDetailsView.Section.Health.Status")
					}
				}

				if health.failingStreak > 0 {
					LabeledContent("ContainerDetailsView.Section.Health.FailingStreak") {
						Text(health.failingStreak.description)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
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
				}
			}
		}
	}

	@ViewBuilder
	private var nameSection: some View {
		if let name = viewModel.container?.displayName ?? viewModel.containerDetails?.displayName ?? navigationItem.displayName {
			NormalizedSection {
				Labeled(name)
					.fontDesign(.monospaced)
			} header: {
				Text("ContainerDetailsView.Section.Name")
			}
		}
	}

	@ViewBuilder
	private var idSection: some View {
		if let id = viewModel.container?.id ?? viewModel.containerDetails?.id {
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
		if let createdAt = viewModel.containerDetails?.created ?? viewModel.container?.created {
			NormalizedSection {
				Labeled(createdAt.formatted(.dateTime))
			} header: {
				Text("ContainerDetailsView.Section.CreatedAt")
			}
		}
	}

	@ViewBuilder
	private var finishedAtSection: some View {
		if let finishedAt = viewModel.containerDetails?.state.finishedAt, !(viewModel.containerDetails?.state.running ?? false) {
			NormalizedSection {
				Labeled(finishedAt.formatted(.dateTime))
			} header: {
				Text("ContainerDetailsView.Section.FinishedAt")
			}
		}
	}

	@ViewBuilder
	private var imageSection: some View {
		if viewModel.container?.image != nil || viewModel.container?.imageID != nil {
			NormalizedSection {
				Group {
					if let image = viewModel.container?.image {
						Labeled(image)
					}

					if let imageID = viewModel.container?.imageID {
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
	private var entrypointSection: some View {
		let entrypoint = viewModel.containerDetails?.config?.entrypoint?.joined(separator: " ")
		let command = viewModel.containerDetails?.config?.cmd?.joined(separator: " ")
		if entrypoint != nil || command != nil {
			NormalizedSection {
				if let entrypoint {
					Labeled(entrypoint)
						.fontDesign(.monospaced)
				}

				if let command {
					Labeled(command)
						.fontDesign(.monospaced)
				}
			} header: {
				Text("ContainerDetailsView.Section.Entrypoint")
			}
		}
	}

	@ViewBuilder
	private var stackSection: some View {
		if let stackName = viewModel.container?.stack {
			let storedStack = portainerStore.stacks.first { $0.name == stackName }

			NormalizedSection {
				LabeledContent("ContainerDetailsView.Stack.Name") {
					Text(stackName)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				if let storedStackID = storedStack?.id {
					LabeledContent("ContainerDetailsView.Stack.ID") {
						Text(storedStackID.description)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}

				Button {
					if let storedStackID = storedStack?.id {
						let navigationItem = StackDetailsView.NavigationItem(stackID: storedStackID.description, stackName: stackName)
						sceneDelegate.navigate(to: .stacks, with: navigationItem)
					} else {
						sceneDelegate.navigate(to: .stacks)
						sceneDelegate.selectedStackNameForStacksView = stackName
					}
				} label: {
					Label("ContainerDetailsView.Stack.ShowStack", systemImage: SFSymbol.stack)
						#if os(macOS)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						#endif
				}
				#if os(macOS)
				.buttonStyle(.plain)
				.foregroundStyle(.accent)
				#endif
			} header: {
				Text("ContainerDetailsView.Stack")
			}
		}
	}

	// MARK: body

	var body: some View {
		Form {
			Group {
				statusSection
				healthSection
				nameSection
				idSection
				createdAtSection
				finishedAtSection
				imageSection
				entrypointSection
			}

			stackSection

			NormalizedSection {
				NavigationLink(value: Subdestination.environment) {
					Label("ContainerDetailsView.Section.Environment", systemImage: SFSymbol.environment)
				}
				.disabled(viewModel.containerDetails?.config?.env == nil)

				NavigationLink(value: Subdestination.labels) {
					Label("ContainerDetailsView.Section.Labels", systemImage: "tag")
				}
				.disabled(viewModel.containerDetails?.config?.labels == nil)

				NavigationLink(value: Subdestination.mounts) {
					Label("ContainerDetailsView.Section.Mounts", systemImage: "externaldrive")
				}
				.disabled(viewModel.containerDetails?.mounts == nil)

				NavigationLink(value: Subdestination.network) {
					Label("ContainerDetailsView.Section.Network", systemImage: SFSymbol.network)
				}
				.disabled(
					(viewModel.container?.ports?.isEmpty ?? true) && (viewModel.containerDetails == nil)
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

					if let container = viewModel.container {
						ContainerContextMenu(
							container: container,
							onContainerAction: {
								viewModel.refresh()
							}
						)
					}
				} label: {
					Label("Generic.More", systemImage: SFSymbol._moreToolbar)
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
		.task(id: navigationItem.id) {
			if viewModel.navigationItem != navigationItem {
				viewModel.viewState = .loading
				viewModel.navigationItem = navigationItem
			}

			do {
				try await viewModel.refresh().value
			} catch {
				errorHandler(error)
			}
		}
		.animation(.default, value: viewModel.container)
		.animation(.default, value: viewModel.containerDetails)
		.animation(.default, value: viewModel.container?.state ?? viewModel.containerDetails?.state.state)
		.animation(.default, value: viewModel.isStatusProgressViewVisible)
		.animation(.default, value: viewModel.fetchTask?.isCancelled)
		.animation(nil, value: navigationItem)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, isActive: sceneDelegate.activeTab == .containers) { userActivity in
			viewModel.createUserActivity(userActivity, for: viewModel.container)
		}
		.navigationTitle(navigationTitle)
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .labels:
				LabelsDetailsView(labels: viewModel.containerDetails?.config?.labels)
			case .environment:
				EnvironmentDetailsView(environment: viewModel.containerDetails?.config?.env)
			case .network:
				NetworkDetailsView(
					ports: viewModel.container?.ports,
					detailNetworkSettings: viewModel.containerDetails?.networkSettings,
					exposedPorts: viewModel.containerDetails?.config?.exposedPorts,
					portBindings: viewModel.containerDetails?.hostConfig.portBindings
				)
			case .mounts:
				MountsDetailsView(mounts: viewModel.containerDetails?.mounts)
			case .logs:
				ContainerLogsView(containerID: navigationItem.id)
			}
		}
		.id(self.id)
	}
}

// MARK: - ContainerDetailsView+Identifiable

extension ContainerDetailsView {
	var id: String {
		"\(Self.self).\(navigationItem.id)"
	}
}

// MARK: - ContainerDetailsView+Equatable

/*
extension ContainerDetailsView: Equatable {
	nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.navigationItem == rhs.navigationItem
	}
}
 */

// MARK: - Previews

#Preview {
	ContainerDetailsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
}

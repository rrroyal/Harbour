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

	// MARK: body

	var body: some View {
		let container = viewModel.container
		let containerDetails = viewModel.containerDetails

		List {
			StatusSection(
				container: container,
				containerDetails: containerDetails,
				isFetching: !(viewModel.fetchTask?.isCancelled ?? true)
			)

			HealthSection(
				health: containerDetails?.state.health
			)

			GeneralSection(
				container: container,
				containerDetails: containerDetails
			)

			EntrypointSection(
				entrypoint: containerDetails?.config?.entrypoint?.joined(separator: " "),
				command: containerDetails?.config?.cmd?.joined(separator: " ")
			)

			StackSection(
				stackName: container?.stack,
				storedStack: portainerStore.stacks.first { $0.name == viewModel.container?.stack }
			)

			NavigationLinksSection(
				container: container,
				containerDetails: containerDetails
			)
		}
		.listStyle(.insetGrouped)
		.scrollContentBackground(.hidden)
		#if os(iOS)
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		#endif
		.toolbar {
			toolbarContent
		}
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await refresh().value
		}
		.task(id: navigationItem.id) {
			if viewModel.navigationItem != navigationItem {
				viewModel.viewState = .loading
				viewModel.navigationItem = navigationItem
			}

			await refresh().value
		}
		.animation(.default, value: container)
		.animation(.default, value: containerDetails)
		.animation(.default, value: container?.state ?? containerDetails?.state.state)
		.animation(.default, value: viewModel.isStatusProgressViewVisible)
		.animation(.default, value: viewModel.fetchTask?.isCancelled)
		.animation(nil, value: navigationItem)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, isActive: sceneDelegate.activeTab == .containers) { userActivity in
			viewModel.createUserActivity(userActivity, for: container)
		}
		.navigationTitle(navigationTitle)
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
			case .devices:
				DevicesDetailsView(devices: containerDetails?.hostConfig.devices)
			case .logs:
				ContainerLogsView(containerID: navigationItem.id)
			}
		}
	}
}

// MARK: - Subviews

private extension ContainerDetailsView {
	struct StatusSection: View {
		let container: Container?
		let containerDetails: ContainerDetails?
		let isFetching: Bool

		var body: some View {
			let state = (container?._isStored ?? true) ? Container.State?.none : (container?.state ?? containerDetails?.state.state ?? Container.State?.none)
			let title = container?.status ?? state.title

			NormalizedSection {
				if state == .none && isFetching {
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
					LabeledTextWithIcon(title, systemImage: state.icon)
						.foregroundStyle(state.color)
				}
			} header: {
				Text("ContainerDetailsView.Section.State")
			}
			.id(container?.state)
			.animation(.default, value: container?.status)
			.animation(.default, value: container?.state)
			.animation(.default, value: containerDetails?.state.state)
			.animation(.default, value: isFetching)
		}
	}

	struct HealthSection: View {
		let health: ContainerDetails.State.Health?

		var body: some View {
			if let health {
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
	}

	struct GeneralSection: View {
		let container: Container?
		let containerDetails: ContainerDetails?

		var body: some View {
			NormalizedSection {
				LabeledContent("ContainerDetailsView.Section.General.Name") {
					LabeledText(container?.displayName)
						.fontDesign(.monospaced)
						.multilineTextAlignment(.trailing)
						.textSelection(.enabled)
				}

				LabeledContent("ContainerDetailsView.Section.General.ID") {
					LabeledText(container?.id)
						.fontDesign(.monospaced)
						.multilineTextAlignment(.leading)
						.textSelection(.enabled)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.labeledContentStyle(.twoLine)

				if let createdAt = container?.created {
					LabeledContent("ContainerDetailsView.Section.General.CreatedAt") {
						LabeledText(createdAt.formatted(.dateTime))
							.multilineTextAlignment(.trailing)
					}
				}

				if let finishedAt = containerDetails?.state.finishedAt, !(containerDetails?.state.running ?? false) {
					LabeledContent("ContainerDetailsView.Section.General.FinishedAt") {
						LabeledText(finishedAt.formatted(.dateTime))
							.multilineTextAlignment(.trailing)
					}
				}

				if let image = container?.image ?? containerDetails?.image {
					LabeledContent("ContainerDetailsView.Section.General.Image") {
						LabeledText(image)
							.fontDesign(.monospaced)
							.multilineTextAlignment(.trailing)
							.textSelection(.enabled)
					}
					.contextMenu {
						CopyButton(content: image)

						if let imageID = container?.imageID {
							Divider()

							CopyButton(content: imageID) {
								Label("ContainerDetailsView.Section.General.Image.CopyImageID", systemImage: SFSymbol.copy)

								Text(imageID)
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					}
				}
			}
		}
	}

	struct EntrypointSection: View {
		let entrypoint: String?
		let command: String?

		var body: some View {
			if entrypoint != nil || command != nil {
				NormalizedSection {
					if let entrypoint {
						LabeledText(entrypoint)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
					}

					if let command {
						LabeledText(command)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
					}
				} header: {
					Text("ContainerDetailsView.Section.Entrypoint")
				}
			}
		}
	}

	struct StackSection: View {
		@Environment(SceneDelegate.self) private var sceneDelegate

		let stackName: String?
		let storedStack: Stack?

		var body: some View {
			if let stackName {
				NormalizedSection {
					LabeledContent("ContainerDetailsView.Section.Stack.Name") {
						LabeledText(stackName)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}

					if let storedStackID = storedStack?.id {
						LabeledContent("ContainerDetailsView.Section.Stack.ID") {
							LabeledText(storedStackID.description)
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
						Label("ContainerDetailsView.Section.Stack.ShowStack", systemImage: SFSymbol.stack)
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
					Text("ContainerDetailsView.Section.Stack")
				}
			}
		}
	}

	struct NavigationLinksSection: View {
		let container: Container?
		let containerDetails: ContainerDetails?

		var body: some View {
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
					Label("ContainerDetailsView.Section.Mounts", systemImage: "folder")
				}
				.disabled(containerDetails?.mounts == nil)

				if !(containerDetails?.hostConfig.devices?.isEmpty ?? true) {
					NavigationLink(value: Subdestination.devices) {
						Label("ContainerDetailsView.Section.Devices", systemImage: "externaldrive")
					}
				}

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
	}

	@ToolbarContentBuilder
	var toolbarContent: some ToolbarContent {
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

//		ToolbarItem(placement: .status) {
//			DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//				ProgressView()
//			}
//		}
	}
}

// MARK: - Actions

private extension ContainerDetailsView {
	@discardableResult
	func refresh() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.refresh().value
			} catch {
				errorHandler(error)
			}
		}
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

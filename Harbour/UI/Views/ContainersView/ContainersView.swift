//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import CoreSpotlight
import IndicatorsKit
import Navigation
import PortainerKit
import SwiftUI

// MARK: - ContainersView

struct ContainersView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences
	@Environment(AppState.self) private var appState
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@State private var viewModel = ViewModel()
	@FocusState private var isFocused: Bool
	@Namespace private var namespace

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate
		let containers = viewModel.containers

		ContainersList(containers: containers)
			.scrollContentBackground(.hidden)
			.background {
				if containers.isEmpty {
					backgroundPlaceholder
				}
			}
			#if os(iOS)
			.background(.groupedBackground, ignoresSafeAreaEdges: .all)
			#elseif os(macOS)
			.background(.clear, ignoresSafeAreaEdges: .all)
			#endif
			.searchable(
				text: $viewModel.searchText,
				tokens: $viewModel.searchTokens,
				suggestedTokens: .constant(viewModel.suggestedSearchTokens),
				isPresented: $viewModel.isSearchActive,
				placement: {
					#if os(iOS)
					.automatic
					#elseif os(macOS)
					.toolbarPrincipal
					#endif
				}()
			) { token in
				Label(token.title, systemImage: token.icon)
			}
			.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
				await fetch()
			}
			.toolbar {
				toolbarContent
			}
			.focusable()
			.focused($isFocused)
			.focusEffectDisabled()
			.confirmationDialog(
				"Generic.AreYouSure",
				isPresented: sceneDelegate.isRemoveContainerAlertPresented,
				titleVisibility: .visible,
				presenting: sceneDelegate.containerToRemove
			) { container in
				Button("Generic.Remove", role: .destructive) {
					Haptics.generateIfEnabled(.heavy)
					removeContainer(container, force: true)
				}
				.tint(.red)
			} message: { container in
				Text("ContainersView.RemoveContainerAlert.Message ContainerName:\(container.displayName ?? container.id)")
			}
			.animation(.default, value: viewModel.viewState)
			.animation(.default, value: viewModel.containers)
			.animation(.default, value: viewModel.isStatusProgressViewVisible)
//			.animation(.default, value: portainerStore.removedContainerIDs)
			.navigationTitle(navigationTitle)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.environment(viewModel)
			.onKeyPress(action: onKeyPress)
			.onChange(of: sceneDelegate.selectedStackNameForContainersView) { _, stackName in
				viewModel.filterByStackName(stackName)
			}
//			.onChange(of: viewModel.searchTokens) { _, tokens in
//				sceneDelegate.selectedStackNameForContainersView = tokens
//					.compactMap {
//						if case .stack(let stackName) = $0 {
//							return stackName
//						}
//						return nil
//					}
//					.last
//			}
			.onContinueUserActivity(CSQueryContinuationActionType) { userActivity in
//				guard sceneDelegate.activeTab == .containers else { return }
				viewModel.handleSpotlightSearchContinuation(userActivity)
			}
			.task {
				if portainerStore.containersTask?.isCancelled ?? true {
					await fetch()
				}
			}
	}
}

// MARK: - Support

private extension ContainersView {
	var navigationTitle: String {
		if let selectedEndpoint = portainerStore.selectedEndpoint {
			return selectedEndpoint.name ?? selectedEndpoint.id.description
		}
		return String(localized: "AppName")
	}

	var selectedEndpointTitle: String {
		if let selectedEndpoint = portainerStore.selectedEndpoint {
			selectedEndpoint.name ?? selectedEndpoint.id.description
		} else if !portainerStore.endpoints.isEmpty {
			String(localized: "ContainersView.NoEndpointSelected")
		} else {
			String(localized: "ContainersView.NoEndpointsAvailable")
		}
	}
}

// MARK: - Subviews

private extension ContainersView {
	@ViewBuilder @MainActor
	var endpointPicker: some View {
		let selectedEndpointBinding = Binding<Endpoint?>(
			get: { portainerStore.selectedEndpoint },
			set: {
				Haptics.generateIfEnabled(.light)
				portainerStore.setSelectedEndpoint($0)
			}
		)
		Picker(selection: selectedEndpointBinding) {
			ForEach(portainerStore.endpoints) { endpoint in
				Text(endpoint.name ?? endpoint.id.description)
					.tag(endpoint)
			}
		} label: {
			Text(selectedEndpointTitle)
		}
		.labelStyle(.titleAndIcon)
		.disabled(!viewModel.canUseEndpointsMenu)
	}

	@ToolbarContentBuilder @MainActor
	var toolbarContent: some ToolbarContent {
		ToolbarItem(placement: .automatic) {
			Menu {
				if !(appState.lastContainerChanges?.isEmpty ?? true) {
					Button {
						Haptics.generateIfEnabled(.sheetPresentation)
						sceneDelegate.isContainerChangesSheetPresented = true
					} label: {
						Label("ContainersView.Menu.ShowLastContainerChanges", systemImage: "arrow.left.arrow.right")
					}

					Divider()
				}

				Picker(selection: $preferences.cvUseGrid.withHaptics(.selectionChanged)) {
					Label("ContainersView.Menu.ContainerLayout.Grid", systemImage: "square.grid.2x2")
						.tag(true)

					Label("ContainersView.Menu.ContainerLayout.List", systemImage: "rectangle.grid.1x2")
						.tag(false)
				} label: {
					Label("ContainersView.Menu.ContainerLayout", systemImage: "rectangle.3.group")
				}
				.pickerStyle(.menu)

				#if os(iOS)
				Divider()

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					sceneDelegate.isSettingsSheetPresented = true
				} label: {
					Label("SettingsView.Title", systemImage: SFSymbol.settings)
				}
				.keyboardShortcut(",", modifiers: .command)
				.labelStyle(.titleAndIcon)
				#endif
			} label: {
				Label("Generic.More", systemImage: SFSymbol._moreToolbar)
					.labelStyle(.iconOnly)
			}
			.labelStyle(.titleAndIcon)
		}
		#if os(iOS)
		._matchedTransitionSource(id: SettingsView.id, in: namespace)
		#endif

		#if os(iOS)
		if horizontalSizeClass == .regular {
			ToolbarItem(placement: .navigation) {
				Menu {
					endpointPicker
				} label: {
					Label(selectedEndpointTitle, systemImage: SFSymbol.endpoint)
						.symbolVariant(portainerStore.selectedEndpoint != nil ? .fill : portainerStore.endpoints.isEmpty ? .slash : .none)
				}
				.labelStyle(.iconOnly)
				.animation(.default, value: portainerStore.endpoints.isEmpty)
				.animation(.default, value: portainerStore.selectedEndpoint)
			}
		} else if horizontalSizeClass == .compact && viewModel.canUseEndpointsMenu {
			ToolbarTitleMenu {
				endpointPicker
			}
		}
		#endif
	}

	@ViewBuilder @MainActor
	private var backgroundPlaceholder: some View {
		let isLoading = viewModel.viewState.isLoading ||
			!(portainerStore.endpointsTask?.isCancelled ?? true) ||
			!(portainerStore.containersTask?.isCancelled ?? true) ||
			!(appState.portainerServerSwitchTask?.isCancelled ?? true)

		if isLoading {
			ProgressView()
		} else if case .failure = viewModel.viewState {
			viewModel.viewState.backgroundView
		} else if !portainerStore.isSetup {
			ContentUnavailableView(
				"Portainer.NotSetup.Title",
				systemImage: SFSymbol.network,
				description: Text("Portainer.NotSetup.Description")
			)
			.symbolVariant(.slash)
		} else if portainerStore.selectedEndpoint == nil {
			if portainerStore.endpoints.isEmpty {
				ContentUnavailableView(
					"ContainersView.NoEndpointsPlaceholder.Title",
					systemImage: SFSymbol.xmark,
					description: Text("ContainersView.NoEndpointsPlaceholder.Description")
				)
			} else {
				let error = PortainerError.noSelectedEndpoint
				let description: Text? = if let recoverySuggestion = error.recoverySuggestion {
					Text(recoverySuggestion)
				} else {
					nil
				}
				ContentUnavailableView(
					error.localizedDescription,
					systemImage: SFSymbol.error,
					description: description
				)
			}
		} else if !viewModel.searchText.isEmpty {
			ContentUnavailableView.search(text: viewModel.searchText)
		} else {
			ContentUnavailableView(
				"ContainersView.NoContainersPlaceholder.Title",
				image: SFSymbol.Custom.container
			)
			.symbolVariant(.slash)
		}
	}
}

// MARK: - Actions

private extension ContainersView {
	func fetch() async {
		guard portainerStore.isSetup else { return }

		do {
			try await viewModel.fetch()
		} catch {
			errorHandler(error)
		}
	}

	func removeContainer(_ container: Container, force: Bool) {
		Task {
			do {
				presentIndicator(.containerRemove(containerName: container.displayName ?? container.id, state: .loading))

				try await portainerStore.removeContainer(containerID: container.id, force: force)
				presentIndicator(.containerRemove(containerName: container.displayName ?? container.id, state: .success))

				sceneDelegate.navigate(to: .containers)
			} catch {
				presentIndicator(.containerRemove(containerName: container.displayName ?? container.id, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func onKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
		switch keyPress.key {
		// ⌘F
		case "f" where keyPress.modifiers.contains(.command):
			viewModel.isSearchActive = true
			return .handled
		default:
			return .ignored
		}
	}
}

// MARK: - Supporting Views

private extension ContainersView {
	struct ContainersList: View {
		@EnvironmentObject private var portainerStore: PortainerStore
		@EnvironmentObject private var preferences: Preferences
		let containers: [Container]

		var body: some View {
			ZStack {
				if preferences.cvUseGrid {
					GridView(containers: containers)
				} else {
					ListView(containers: containers)
				}
			}
			.animation(.default, value: preferences.cvUseGrid)
		}
	}
}

// MARK: - Previews

#Preview {
	ContainersView()
		.withEnvironment()
		.environment(SceneDelegate())
}

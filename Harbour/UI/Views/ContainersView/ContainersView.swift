//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
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
	@State private var viewModel = ViewModel()
	@FocusState private var isFocused: Bool

	private var navigationTitle: String {
		if let selectedEndpoint = portainerStore.selectedEndpoint {
			return selectedEndpoint.name ?? selectedEndpoint.id.description
		}
		return String(localized: "AppName")
	}

	@ViewBuilder
	private var endpointPicker: some View {
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
					.tag(endpoint as Endpoint?)
			}
		} label: {
			let title = if let selectedEndpoint = portainerStore.selectedEndpoint {
				selectedEndpoint.name ?? selectedEndpoint.id.description
			} else if portainerStore.endpoints.isEmpty {
				String(localized: "ContainersView.NoEndpointsAvailable")
			} else {
				String(localized: "ContainersView.NoEndpointSelected")
			}
			Text(title)
		}
		.disabled(!viewModel.canUseEndpointsMenu)
	}

	@ToolbarContentBuilder
	private var toolbarContent: some ToolbarContent {
		#if os(macOS)
		ToolbarItem(placement: .primaryAction) {
			endpointPicker
				.labelStyle(.titleAndIcon)
		}
		#endif

		ToolbarItem(placement: .automatic) {
			Menu {
				let useGridBinding = Binding<Bool>(
					get: { preferences.cvUseGrid },
					set: {
						Haptics.generateIfEnabled(.selectionChanged)
						preferences.cvUseGrid = $0
					}
				)
				Picker(selection: useGridBinding) {
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
				Label("Generic.More", systemImage: SFSymbol.moreCircle)
					.labelStyle(.iconOnly)
			}
			.labelStyle(.titleAndIcon)
		}
	}

	@ViewBuilder
	private var backgroundPlaceholder: some View {
		Group {
			if !portainerStore.isSetup {
				ContentUnavailableView(
					"Generic.NotSetup.Title",
					systemImage: SFSymbol.network,
					description: Text("Generic.NotSetup.Description")
				)
				.symbolVariant(.slash)
			} else if portainerStore.endpoints.isEmpty {
				ContentUnavailableView(
					"ContainersView.NoEndpointsPlaceholder.Title",
					systemImage: SFSymbol.xmark,
					description: Text("ContainersView.NoEndpointsPlaceholder.Description")
				)
			} else if viewModel.containers.isEmpty {
				if viewModel.viewState.isLoading {
					ProgressView()
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
	}

	var body: some View {
		ContainersList()
			.background {
				if viewModel.isBackgroundPlaceholderVisible {
					backgroundPlaceholder
				}
			}
			#if os(iOS)
			.background(
				viewState: viewModel.viewState,
				backgroundVisiblity: .hidden,
				backgroundColor: .groupedBackground
			)
			#elseif os(macOS)
			.background(
				viewState: viewModel.viewState,
				backgroundVisiblity: .hidden,
				backgroundColor: .clear
			)
			#endif
			.searchable(
				text: $viewModel.searchText,
				tokens: $viewModel.searchTokens,
				suggestedTokens: .constant(viewModel.suggestedSearchTokens),
				isPresented: $viewModel.isSearchActive
			) { token in
				Label(token.title, systemImage: token.icon)
			}
			.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
				await fetch().value
			}
			.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
				ContainerDetailsView(navigationItem: navigationItem)
//					.equatable()
//					.tag(navigationItem.id)
			}
			.navigationTitle(navigationTitle)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				toolbarContent
			}
			.if(viewModel.canUseEndpointsMenu) {
				$0.toolbarTitleMenu { endpointPicker }
			}
			.focusable()
			.focused($isFocused)
			.focusEffectDisabled()
			.confirmationDialog(
				"Generic.AreYouSure?",
				isPresented: $viewModel.isRemoveContainerAlertPresented,
				titleVisibility: .visible,
				presenting: viewModel.containerToRemove
			) { container in
				Button("Generic.Remove", role: .destructive) {
					Haptics.generateIfEnabled(.heavy)
					removeContainer(container, force: true)
				}
			} message: { container in
				Text("ContainersView.RemoveContainerAlert.Message ContainerName:\(container.displayName ?? container.id)")
			}
			.animation(.easeInOut, value: viewModel.viewState)
			.animation(.easeInOut, value: viewModel.containers)
			.animation(.easeInOut, value: viewModel.isStatusProgressViewVisible)
			.environment(viewModel)
			.onKeyPress(action: onKeyPress)
			.onChange(of: sceneDelegate.selectedStackName) { _, stackName in
				viewModel.filterByStackName(stackName)
			}
			.onChange(of: viewModel.searchTokens) { _, tokens in
				sceneDelegate.selectedStackName = tokens
					.compactMap {
						if case .stack(let stackName) = $0 {
							return stackName
						}
						return nil
					}
					.last
			}
			.task {
				if portainerStore.containersTask?.isCancelled ?? true {
					await fetch().value
				}
			}
//			.onAppear {
//				isFocused = true
//			}
	}
}

// MARK: - ContainersView+ContainersList

private extension ContainersView {
	struct ContainersList: View {
		@Environment(ContainersView.ViewModel.self) private var viewModel
		@EnvironmentObject private var portainerStore: PortainerStore
		@EnvironmentObject private var preferences: Preferences

		var body: some View {
			ScrollView {
				Group {
					if preferences.cvUseGrid {
						GridView(containers: viewModel.containers)
					} else {
						ListView(containers: viewModel.containers)
					}
				}
				.padding(.horizontal)
				.padding(.bottom)
				#if os(macOS)
				.padding(.top)
				#endif
				.transition(.opacity)
				.animation(.easeInOut, value: portainerStore.containers)
				.animation(.easeInOut, value: portainerStore.removedContainerIDs)
				.animation(.easeInOut, value: preferences.cvUseGrid)
			}
		}
	}
}

// MARK: - ContainersView+Actions

private extension ContainersView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			guard portainerStore.isSetup else { return }

			do {
				try await viewModel.fetch()
			} catch {
				errorHandler(error)
			}
		}
	}

	func removeContainer(_ container: Container, force: Bool) {
		Task {
			do {
				presentIndicator(.containerRemove(container.displayName ?? container.id, state: .loading))
				try await viewModel.removeContainer(container, force: force)
				presentIndicator(.containerRemove(container.displayName ?? container.id, state: .success))
			} catch {
				presentIndicator(.containerRemove(container.displayName ?? container.id, state: .failure(error)))
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

// MARK: - Previews

#Preview {
	ContainersView()
		.withEnvironment(appState: .shared)
		.environment(SceneDelegate())
}

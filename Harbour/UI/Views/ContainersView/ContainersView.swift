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
	@Environment(\.cvUseGrid) private var useGrid
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()

	private let supportedKeyShortcuts: Set<KeyEquivalent> = [
		"f",	// ⌘F - Search
		"r",	// ⌘R - Refresh
		","		// ⌘, - Settings
	]

	private var navigationTitle: String {
		if let selectedEndpoint = portainerStore.selectedEndpoint {
			return selectedEndpoint.name ?? selectedEndpoint.id.description
		}
		return String(localized: "AppName")
	}

	private var endpointsMenuTitle: String {
		if let selectedEndpoint = portainerStore.selectedEndpoint {
			return selectedEndpoint.name ?? selectedEndpoint.id.description
		}
		if portainerStore.endpoints.isEmpty {
			return String(localized: "ContainersView.NoEndpointsAvailable")
		}
		return String(localized: "ContainersView.NoEndpointSelected")
	}

	@ViewBuilder
	private var toolbarTitleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			let binding = Binding<Bool>(
				get: { portainerStore.selectedEndpoint?.id == endpoint.id },
				set: { _ in
					viewModel.selectEndpoint(endpoint)
					Haptics.generateIfEnabled(.light)
				}
			)
			Toggle(String(endpoint.name ?? endpoint.id.description), isOn: binding)
		}
	}

	@ToolbarContentBuilder
	private var toolbarMenu: some ToolbarContent {
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
					Label("ContainersView.Menu.ContainersLayout.Grid", systemImage: "square.grid.2x2")
						.tag(true)

					Label("ContainersView.Menu.ContainersLayout.List", systemImage: "rectangle.grid.1x2")
						.tag(false)
				} label: {
					Label("ContainersView.Menu.ContainersLayout", systemImage: "rectangle.3.group")
				}
				.pickerStyle(.menu)

				Divider()

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					sceneDelegate.isSettingsSheetPresented = true
				} label: {
					Label("SettingsView.Title", systemImage: SFSymbol.settings)
				}
				.keyboardShortcut(",", modifiers: .command)
				.labelStyle(.titleAndIcon)
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
					"Generic.NotSetup",
					systemImage: SFSymbol.network,
					description: Text("ContainersView.NotSetupPlaceholder.Description")
				)
				.symbolVariant(.slash)
			} else if portainerStore.endpoints.isEmpty {
				ContentUnavailableView(
					"ContainersView.NoEndpointsPlaceholder.Title",
					systemImage: SFSymbol.xmark,
					description: Text("ContainersView.NoEndpointsPlaceholder.Description")
				)
			} else if viewModel.containers.isEmpty {
				if !viewModel.searchText.isEmpty {
					ContentUnavailableView.search(text: viewModel.searchText)
				} else {
					ContentUnavailableView(
						"ContainersView.NoContainersPlaceholder.Title",
						systemImage: SFSymbol.xmark
					)
				}
			}
		}
	}

	@ViewBuilder
	private var content: some View {
		ScrollView {
			Group {
				if useGrid {
					GridView(containers: viewModel.containers)
				} else {
					ListView(containers: viewModel.containers)
				}
			}
			.padding(.horizontal)
			.padding(.bottom)
			.transition(.opacity)
		}
		.scrollDismissesKeyboard(.interactively)
		.background {
			if viewModel.isEmptyPlaceholderVisible {
				backgroundPlaceholder
			}
		}
		.background(
			viewState: viewModel.viewState,
			isViewStateBackgroundVisible: viewModel.isEmptyPlaceholderVisible,
			backgroundColor: .groupedBackground
		)
//		.background {
//			if viewModel.isViewStateBackgroundVisible {
//				viewModel.viewState.backgroundView
//			}
//		}
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
				.equatable()
				.tag(navigationItem.id)
		}
		.navigationTitle(navigationTitle)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
			#if os(macOS)
			ToolbarItem(placement: .principal) {
				Menu {
					toolbarTitleMenu
				} label: {
					Text(endpointsMenuTitle)
				}
				.disabled(!viewModel.canUseEndpointsMenu)
				.labelStyle(.titleAndIcon)
			}
			#endif

			#if os(iOS)
			toolbarMenu
			#endif

//			ToolbarItem(placement: .status) {
//				DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//					ProgressView()
//				}
//				.transition(.opacity)
//			}
		}
		.if(viewModel.canUseEndpointsMenu) {
			$0.toolbarTitleMenu { toolbarTitleMenu }
		}
	}

	// MARK: Body

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate
		NavigationWrapped(navigationPath: $sceneDelegate.navigationPathContainers) {
			content
		} placeholderContent: {
			Text("ContainersView.NoContainerSelectedPlaceholder")
				.foregroundStyle(.tertiary)
		}
		.focusable()
		.focusEffectDisabled()
		.animation(.easeInOut, value: useGrid)
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.containers)
		.animation(.easeInOut, value: viewModel.isStatusProgressViewVisible)
		.environment(viewModel)
		.onKeyPress(keys: supportedKeyShortcuts, action: onKeyPress)
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
	}
}

// MARK: - ContainersView+Actions

private extension ContainersView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.refresh()
			} catch {
				errorHandler(error)
			}
		}
	}

	func onKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
		switch keyPress.key {
		// ⌘F
		case "f" where keyPress.modifiers.contains(.command):
			viewModel.isSearchActive = true
			return .handled
		// ⌘R
		case "r" where keyPress.modifiers.contains(.command):
			Task {
				do {
					try await viewModel.refresh()
				} catch {
					errorHandler(error)
				}
			}
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

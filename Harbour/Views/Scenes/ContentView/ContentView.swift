//
//  ContentView.swift
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

// MARK: - ContentView

struct ContentView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences
	@Environment(AppState.self) private var appState
	@State private var sceneState = SceneState()
	@State private var viewModel = ViewModel()

	private let supportedKeyShortcuts: Set<KeyEquivalent> = [
		"f",	// ⌘F - Search
		"r",	// ⌘R - Refresh
		"s",	// ⇧⌘S - Stacks
		","		// ⌘, - Settings
	]

	@ViewBuilder
	private var toolbarTitleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			Button {
				Haptics.generateIfEnabled(.light)
				viewModel.selectEndpoint(endpoint)
			} label: {
				let isSelected = portainerStore.selectedEndpoint?.id == endpoint.id
				Label(endpoint.name ?? endpoint.id.description, systemImage: SFSymbol.checkmark)
					.labelStyle(.iconOptional(showIcon: isSelected))
			}
		}
	}

	@ToolbarContentBuilder
	private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button {
				sceneState.isStacksSheetPresented = true
			} label: {
				Label("ContentView.NavigationButton.Stacks", systemImage: SFSymbol.stack)
			}
			.keyboardShortcut("s", modifiers: [.command, .shift])
		}

		#if os(iOS)
		ToolbarItem(placement: .automatic) {
			Button {
				sceneState.isSettingsSheetPresented = true
			} label: {
				Label("ContentView.NavigationButton.Settings", systemImage: SFSymbol.settings)
			}
			.keyboardShortcut(",", modifiers: .command)
		}
		#endif

		#if os(macOS)
		ToolbarItem(placement: .principal) {
			Menu {
				toolbarTitleMenu
			} label: {
				Text(viewModel.endpointsMenuTitle)
			}
			.disabled(!viewModel.canUseEndpointsMenu)
			.labelStyle(.titleAndIcon)
		}
		#endif
	}

	@ViewBuilder
	private var backgroundPlaceholder: some View {
		Group {
			if !portainerStore.isSetup {
				ContentUnavailableView(
					"Generic.NotSetup",
					systemImage: SFSymbol.network,
					description: Text("ContentView.NotSetupPlaceholder.Description")
				)
				.symbolVariant(.slash)
			} else if portainerStore.endpoints.isEmpty {
				ContentUnavailableView(
					"ContentView.NoEndpointsPlaceholder.Title",
					systemImage: SFSymbol.xmark,
					description: Text("ContentView.NoEndpointsPlaceholder.Description")
				)
			} else if viewModel.containers.isEmpty {
				if !viewModel.searchText.isEmpty {
					ContentUnavailableView.search(text: viewModel.searchText)
				} else {
					ContentUnavailableView(
						"ContentView.NoContainersPlaceholder.Title",
						systemImage: SFSymbol.xmark
					)
				}
			}
		}
	}

	@ViewBuilder
	private var content: some View {
		ScrollView {
//			#if ENABLE_PREVIEW_FEATURES
//			if isSummaryVisible {
//				VStack {
//					Text("ContentView.Summary")
//					Divider()
//				}
//				.transition(.move(edge: .top).combined(with: .opacity))
//			}
//			#endif

			ContainersView(containers: viewModel.containers)
		}
		.background {
			if viewModel.shouldShowEmptyPlaceholder {
				backgroundPlaceholder
			}
		}
		.background {
			if viewModel.shouldShowViewStateBackground {
				viewModel.viewState.backgroundView
			}
		}
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		.scrollDismissesKeyboard(.interactively)
		.searchable(
			text: $viewModel.searchText,
			tokens: $viewModel.searchTokens,
			suggestedTokens: .constant(viewModel.suggestedSearchTokens),
			isPresented: $viewModel.isSearchActive
		) { token in
			Label(token.title, systemImage: token.icon)
		}
		.refreshable {
			do {
				try await viewModel.refresh()
			} catch {
				handleError(error)
			}
		}
		.navigationTitle(viewModel.navigationTitle)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
			toolbar
		}
		.if(viewModel.canUseEndpointsMenu) {
			$0.toolbarTitleMenu { toolbarTitleMenu }
		}
	}

	// MARK: Body

	var body: some View {
		NavigationWrapped(navigationPath: $sceneState.navigationPath, useColumns: viewModel.shouldUseColumns) {
			content
		} placeholderContent: {
			Text("ContentView.NoContainerSelectedPlaceholder")
				.foregroundStyle(.tertiary)
		}
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
				.indicatorOverlay(model: sceneState.indicators)
		}
		.sheet(isPresented: $sceneState.isStacksSheetPresented) {
			let selectedStackBinding = Binding<Stack?>(
				get: { nil },
				set: { viewModel.onStackTapped($0) }
			)
			StacksView(selectedStack: selectedStackBinding)
		}
		.sheet(isPresented: $viewModel.isLandingSheetPresented) {
			viewModel.onLandingDismissed()
		} content: {
			LandingView()
				.indicatorOverlay(model: sceneState.indicators)
		}
		.focusable()
		.focusEffectDisabled()
		.indicatorOverlay(model: sceneState.indicators)
		.environment(\.errorHandler, .init(handleError))
		.environment(\.showIndicator, sceneState.showIndicator)
		.environment(\.navigationPath, sceneState.navigationPath)
		.withNavigation(handler: sceneState)
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails, perform: sceneState.onContinueContainerDetailsActivity)
		.onKeyPress(keys: supportedKeyShortcuts, action: onKeyPress)
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.containers)
		.animation(.easeInOut, value: portainerStore.isSetup)
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
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
					handleError(error)
				}
			}
			return .handled
		default:
			return .ignored
		}
	}

	func handleError(_ error: Error, _debugInfo: String = ._debugInfo()) {
		sceneState.handleError(error, _debugInfo: _debugInfo)
	}
}

// MARK: - Previews

#Preview {
	ContentView()
		.environment(AppState.shared)
		.environment(SceneState())
		.environmentObject(PortainerStore.shared)
		.environmentObject(Preferences.shared)
}

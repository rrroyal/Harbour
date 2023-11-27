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
import PortainerKit
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
	@EnvironmentObject private var appDelegate: AppDelegate
	@EnvironmentObject private var sceneDelegate: SceneDelegate
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences
	@Environment(AppState.self) private var appState
	@Environment(\.errorHandler) private var errorHandler

	@State private var viewModel = ViewModel()

	private let supportedKeyShortcuts: Set<KeyEquivalent> = [
		"f",	// ⌘F - Search
		"r"		// ⌘R - Refresh
	]

	@ViewBuilder
	private var titleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			Button {
				Haptics.generateIfEnabled(.light)
				viewModel.selectEndpoint(endpoint)
			} label: {
				let isSelected = portainerStore.selectedEndpoint?.id == endpoint.id
				Label(endpoint.name ?? endpoint.id.description, systemImage: isSelected ? SFSymbol.checkmark : "")
			}
		}
	}

	@ToolbarContentBuilder
	private var toolbarMenu: some ToolbarContent {
		ToolbarItem(placement: .primaryAction) {
			Button {
//				Haptics.generateIfEnabled(.sheetPresentation)
				sceneDelegate.isSettingsSheetPresented = true
			} label: {
				Label("ContentView.NavigationButton.Settings", systemImage: SFSymbol.settings)
			}
			.keyboardShortcut(",", modifiers: .command)
		}

		ToolbarItem(placement: .navigation) {
			Button {
				sceneDelegate.isStacksSheetPresented = true
			} label: {
				Label("ContentView.NavigationButton.Stacks", systemImage: SFSymbol.stack)
//					.symbolVariant(portainerStore.isSetup ? .none : .slash)
			}
			.keyboardShortcut("s", modifiers: .command)
		}
	}

	@ViewBuilder
	private var containersView: some View {
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

			ContainersView(viewModel.containers)
				.transition(.opacity)
				.animation(.easeInOut, value: viewModel.containers)
		}
		.background {
			if viewModel.shouldShowEmptyPlaceholderView {
				ContainersView.NoContainersPlaceholder(isEmpty: viewModel.containers.isEmpty, searchQuery: viewModel.searchText)
			}
		}
		.modifier(
			ContainersView.ListModifier {
				viewModel.viewState.backgroundView
			}
		)
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
				errorHandler(error)
			}
		}
	}

	// MARK: Body

	var body: some View {
		NavigationWrapped(useColumns: viewModel.shouldUseColumns) {
			containersView
				.navigationTitle(viewModel.navigationTitle)
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.toolbarTitleMenu {
					titleMenu
				}
				.toolbar {
					toolbarMenu
				}
		} placeholderContent: {
			Text("ContentView.NoContainerSelectedPlaceholder")
				.foregroundStyle(.tertiary)
		}
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
				.indicatorOverlay(model: sceneDelegate.indicators)
		}
		.sheet(isPresented: $sceneDelegate.isStacksSheetPresented) {
			let selectedStackBinding = Binding<Stack?>(get: { nil }, set: { viewModel.onStackTapped($0) })
			StacksView(selectedStack: selectedStackBinding)
		}
		.sheet(isPresented: $viewModel.isLandingSheetPresented) {
			viewModel.onLandingDismissed()
		} content: {
			LandingView()
				.indicatorOverlay(model: sceneDelegate.indicators)
		}
		.indicatorOverlay(model: sceneDelegate.indicators)
		.environment(\.errorHandler, .init(sceneDelegate.handleError))
		.environment(\.showIndicator, sceneDelegate.showIndicator)
		.environmentObject(sceneDelegate.indicators)
		.onOpenURL(perform: sceneDelegate.onOpenURL)
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails, perform: sceneDelegate.onContinueContainerDetailsActivity)
		.onKeyPress(keys: supportedKeyShortcuts, action: onKeyPress)
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
	ContentView()
		.environment(AppState.shared)
		.environmentObject(PortainerStore.shared)
		.environmentObject(Preferences.shared)
		.environmentObject(SceneDelegate())
}

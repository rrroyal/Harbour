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
	@Environment(SceneState.self) private var sceneState
	@Environment(\.cvUseGrid) private var useGrid
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()

	private let supportedKeyShortcuts: Set<KeyEquivalent> = [
		"f",	// ⌘F - Search
		"r",	// ⌘R - Refresh
		","		// ⌘, - Settings
	]

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
					ContainersGridView(containers: viewModel.containers)
				} else {
					ContainersListView(containers: viewModel.containers)
				}
			}
			.padding(.horizontal)
			.padding(.bottom)
			.transition(.opacity)
		}
		.scrollDismissesKeyboard(.interactively)
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
		.searchable(
			text: $viewModel.searchText,
			tokens: $viewModel.searchTokens,
			suggestedTokens: .constant(viewModel.suggestedSearchTokens),
			isPresented: $viewModel.isSearchActive
		) { token in
			Label(token.title, systemImage: token.icon)
		}
		.refreshable {
			await refresh()
		}
		.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
			ContainerDetailsView(navigationItem: navigationItem)
				.equatable()
		}
		.navigationTitle(viewModel.navigationTitle)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
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

			#if os(iOS)
			ToolbarItem(placement: .automatic) {
				Menu {
					Button {
						Haptics.generateIfEnabled(.sheetPresentation)
						sceneState.isSettingsSheetPresented = true
					} label: {
						Label("SettingsView.Title", systemImage: SFSymbol.settings)
					}
					.keyboardShortcut(",", modifiers: .command)
				} label: {
					Label("Generic.More", systemImage: SFSymbol.moreCircle)
				}
			}
			#endif
		}
		.if(viewModel.canUseEndpointsMenu) {
			$0.toolbarTitleMenu { toolbarTitleMenu }
		}
	}

	// MARK: Body

	var body: some View {
		@Bindable var sceneState = sceneState
		NavigationWrapped(navigationPath: $sceneState.navigationPathContainers) {
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
		.onKeyPress(keys: supportedKeyShortcuts, action: onKeyPress)
		.onChange(of: sceneState.selectedStackName) { _, stackName in
			viewModel.filterByStackName(stackName)
		}
		.onChange(of: viewModel.searchTokens) { _, tokens in
			sceneState.selectedStackName = tokens
				.compactMap {
					if case .stack(let stackName) = $0 {
						return stackName
					}
					return nil
				}
				.last
		}
		.task { await refresh() }
	}
}

// MARK: - ContainersView+Actions

private extension ContainersView {
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

	func refresh() async {
		do {
			try await viewModel.refresh()
		} catch {
			errorHandler(error)
		}
	}
}

// MARK: - Previews

#Preview {
	ContainersView()
		.withEnvironment(appState: .shared)
		.environment(SceneState())
}

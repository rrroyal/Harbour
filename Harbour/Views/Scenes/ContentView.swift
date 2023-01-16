//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//

import SwiftUI
import PortainerKit
import IndicatorsKit
import CommonFoundation
import CommonHaptics

// MARK: - ContentView

struct ContentView: View {
	private typealias Localization = Localizable.ContentView

	@EnvironmentObject private var appDelegate: AppDelegate
	@EnvironmentObject private var sceneDelegate: SceneDelegate
	@EnvironmentObject private var appState: AppState
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences

	@State private var searchFilter: String = ""
	@State private var refreshTask: Task<Void, Error>?
	@State private var isLandingSheetPresented = !Preferences.shared.landingDisplayed

	private var shouldUseColumns: Bool {
		guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
			return false
		}

		return preferences.cvUseColumns
	}

	private var navigationTitle: String {
		portainerStore.selectedEndpoint?.name ?? Localizable.ContentView.noEndpointSelected
	}

	private var containers: [Container] {
		portainerStore.containers.filtered(query: searchFilter)
	}

	@ViewBuilder
	private var titleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			Button(action: {
				Haptics.generateIfEnabled(.light)
				selectEndpoint(endpoint)
			}) {
				Text(endpoint.name ?? endpoint.id.description)
				if portainerStore.selectedEndpoint?.id == endpoint.id {
					Image(systemName: SFSymbol.selected)
				}
			}
		}
	}

	@ViewBuilder
	private var placeholderBackground: some View {
		ZStack {
			Color(uiColor: .systemGroupedBackground)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.ignoresSafeArea()

			if portainerStore.containers.isEmpty {
				Group {
					if portainerStore.serverURL == nil {
						Text(Localizable.ContainersView.noSelectedServerPlaceholder)
//					} else if sceneDelegate.isLoading {
//						Text(Localizable.ContainersView.loadingPlaceholder)
					} else if portainerStore.selectedEndpoint == nil {
						Text(Localizable.ContainersView.noSelectedEndpointPlaceholder)
					} else if portainerStore.endpoints.isEmpty {
						Text(Localizable.ContainersView.noEndpointsPlaceholder)
					} else if portainerStore.containers.isEmpty {
						Text(Localizable.ContainersView.noContainersPlaceholder)
					}
				}
				.foregroundStyle(.secondary)
				.transition(.opacity)
			}
		}
		.transition(.opacity)
		.animation(.easeInOut, value: portainerStore.serverURL == nil)
//		.animation(.easeInOut, value: sceneDelegate.isLoading)
		.animation(.easeInOut, value: portainerStore.selectedEndpoint == nil)
		.animation(.easeInOut, value: portainerStore.endpoints.isEmpty)
		.animation(.easeInOut, value: portainerStore.containers.isEmpty)

	}

	@ViewBuilder
	private var containersView: some View {
		ScrollView {
			// TODO: Hide summary when searching
			if preferences.cvDisplaySummary {
				// TODO: Summary
				Text("Summary")
				Divider()
			}

			ContainersView(containers: containers)
				.navigationTitle(navigationTitle)
				.navigationBarTitleDisplayMode(.inline)
				.toolbarTitleMenu {
					titleMenu
				}
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							Haptics.generateIfEnabled(.sheetPresentation)
							sceneDelegate.isSettingsSheetPresented.toggle()
						}) {
							Image(systemName: SFSymbol.settings)
						}
					}
				}
				.transition(.opacity)
		}
		.refreshable(action: refresh)
		.searchable(text: $searchFilter, placement: .navigationBarDrawer)
		.scrollDismissesKeyboard(.interactively)
		.background(placeholderBackground)
		.animation(.easeInOut, value: containers)
	}

	@ViewBuilder
	private var containersViewSplit: some View {
		NavigationSplitView(sidebar: {
			containersView
		}) {
			Text(Localization.noContainerSelectedPlaceholder)
				.foregroundStyle(.tertiary)
		}
		.navigationSplitViewColumnWidth(min: 100, ideal: 200, max: .infinity)
	}

	@ViewBuilder
	private var containersViewStack: some View {
		NavigationStack(path: $sceneDelegate.navigationPath) {
			containersView
		}
	}

	// MARK: body

	var body: some View {
		Group {
			if shouldUseColumns {
				containersViewSplit
			} else {
				containersViewStack
			}
		}
		.indicatorOverlay(model: sceneDelegate.indicators)
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $isLandingSheetPresented, onDismiss: {
			onLandingDismiss()
		}) {
			LandingView()
		}
//		.animation(.easeInOut, value: sceneState.isLoading)
		.environment(\.sceneErrorHandler, handleError)
		.onOpenURL { url in
			sceneDelegate.onOpenURL(url)
		}
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails) { userActivity in
			sceneDelegate.onContinueContainerDetailsActivity(userActivity)
		}
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
	@Sendable
	func refresh() async {
		do {
			let task = portainerStore.refresh()
			try await task.value
		} catch {
			handleError(error)
		}
	}

	@MainActor
	func onLandingDismiss() {
		preferences.landingDisplayed = true
	}

	@MainActor
	func selectEndpoint(_ endpoint: Endpoint?) {
		portainerStore.selectEndpoint(endpoint)
	}

	func handleError(_ error: Error, _debugInfo: String = ._debugInfo()) {
		sceneDelegate.handle(error, _debugInfo: _debugInfo)
	}
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(AppState.shared)
			.environmentObject(PortainerStore.shared)
			.environmentObject(Preferences.shared)
	}
}

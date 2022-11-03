//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//

import SwiftUI
import PortainerKit
import IndicatorsKit

// MARK: - ContentView

struct ContentView: View {
	@EnvironmentObject private var appState: AppState
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences
	@StateObject var sceneState = SceneState()

	@State private var isLandingSheetPresented = !Preferences.shared.landingDisplayed

	@ViewBuilder
	private var titleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			Button(action: {
				UIDevice.generateHaptic(.light)
				selectEndpoint(endpoint)
			}) {
				Text(endpoint.name ?? endpoint.id.description)
				if portainerStore.selectedEndpointID == endpoint.id {
					Image(systemName: SFSymbol.selected)
				}
			}
		}

		Divider()

		Button(action: {
			UIDevice.generateHaptic(.light)
			refresh()
		}) {
			Label("Refresh", systemImage: SFSymbol.reload)
		}
	}

	var body: some View {
		NavigationStack(path: $sceneState.navigationPath) {
			ContainersView()
				.navigationTitle(Localizable.appName)
				.navigationBarTitleDisplayMode(.inline)
				.toolbarTitleMenu {
					titleMenu
				}
				.toolbar {
//					ToolbarItem(placement: .navigationBarLeading) {
//						if sceneState.isLoading {
//							ProgressView()
//								.transition(.opacity)
//						}
//					}

//					ToolbarTitle(title: Localizable.appName, subtitle: sceneState.isLoadingMainScreenData ? Localizable.Generic.loading : nil)

					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							UIDevice.generateHaptic(.sheetPresentation)
							sceneState.isSettingsSheetPresented.toggle()
						}) {
							Image(systemName: SFSymbol.settings)
						}
					}
				}
		}
		.indicatorOverlay(model: sceneState.indicators)
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $isLandingSheetPresented, onDismiss: {
			onLandingDismiss()
		}) {
			LandingView()
		}
		.animation(.easeInOut, value: sceneState.isLoading)
		.environment(\.sceneErrorHandler, handleError)
		.environmentObject(sceneState)
		.onOpenURL { url in
			sceneState.onOpenURL(url)
		}
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails) { userActivity in
			sceneState.onContinueContainerDetailsActivity(userActivity)
		}
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
	func refresh() {
		portainerStore.refresh(errorHandler: handleError)
	}

	@MainActor
	func onLandingDismiss() {
		preferences.landingDisplayed = true
	}

	@MainActor
	func selectEndpoint(_ endpoint: Endpoint?) {
		portainerStore.selectEndpoint(endpoint)
	}

	func handleError(_ error: Error, _debugInfo: String) {
		sceneState.handle(error, _debugInfo: _debugInfo)
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

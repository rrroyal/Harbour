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
	@EnvironmentObject var appState: AppState
	@EnvironmentObject var portainerStore: PortainerStore
	@EnvironmentObject var preferences: Preferences
	@StateObject var sceneState = SceneState()

	@State private var isLandingSheetPresented = !Preferences.shared.landingDisplayed

	private var isLoading: Bool {
		let setupCancelled = portainerStore.setupTask?.isCancelled ?? true
		let endpointsCancelled = portainerStore.endpointsTask?.isCancelled ?? true
		let containersCancelled = portainerStore.containersTask?.isCancelled ?? true
		return !setupCancelled || !endpointsCancelled || !containersCancelled
	}

	@ViewBuilder
	private var titleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			Button(action: {
				selectEndpoint(endpoint)
			}) {
				Text(endpoint.name ?? endpoint.id.description)
				if portainerStore.selectedEndpoint == endpoint {
					Image(systemName: "checkmark")
				}
			}
		}
	}

	var body: some View {
		NavigationStack(path: $sceneState.navigationPath) {
			ContainersView(isLoading: isLoading)
				.navigationTitle(Localizable.appName)
				.navigationBarTitleDisplayMode(.inline)
				.toolbarTitleMenu(isVisible: !portainerStore.endpoints.isEmpty) {
					titleMenu
				}
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						if isLoading {
							ProgressView()
								.transition(.opacity)
						}
					}

					ToolbarTitle(title: Localizable.appName, subtitle: sceneState.isLoadingMainScreenData ? Localizable.Generic.loading : nil)

					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							UIDevice.generateHaptic(.sheetPresentation)
							sceneState.isSettingsSheetPresented = true
						}, label: {
							Image(systemName: "gear")
						})
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
		.onAppear { onAppear() }
		.environment(\.sceneErrorHandler, sceneState.handle)
		.environmentObject(sceneState)
		.animation(.easeInOut, value: isLoading)
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
	@MainActor
	func selectEndpoint(_ endpoint: Endpoint?) {
		UIDevice.generateHaptic(.light)
		portainerStore.selectedEndpoint = endpoint
	}

	@MainActor
	func onLandingDismiss() {
		preferences.landingDisplayed = true
	}

	@MainActor
	func onAppear() {
		portainerStore.refreshEndpoints(errorHandler: sceneState.handle)
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

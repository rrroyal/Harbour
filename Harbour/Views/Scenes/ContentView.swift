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

		Divider()

		Button(action: {
			portainerStore.refresh(errorHandler: sceneState.handle)
		}) {
			Label("Refresh", systemImage: "arrow.clockwise")
		}
	}

	var body: some View {
		NavigationStack(path: $sceneState.navigationPath) {
			ContainersView(isLoading: isLoading)
				.navigationTitle(Localizable.appName)
				.navigationBarTitleDisplayMode(.inline)
				.toolbarTitleMenu {
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
		.animation(.easeInOut, value: isLoading)
		.environment(\.sceneErrorHandler, sceneState.handle)
		.environmentObject(sceneState)
		.onContinueUserActivity(HarbourUserActivity.containerDetails, perform: onContinueContainerDetailsActivity)
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
	@MainActor
	func onLandingDismiss() {
		preferences.landingDisplayed = true
	}

	@MainActor
	func selectEndpoint(_ endpoint: Endpoint?) {
		UIDevice.generateHaptic(.light)
		portainerStore.selectEndpoint(endpoint)
	}

	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		guard let data = try? userActivity.typedPayload(ContainersView.ContainerNavigationItem.self) else {
			return
		}
		sceneState.navigationPath.append(data)
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

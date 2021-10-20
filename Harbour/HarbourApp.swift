//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import SwiftUI
import Indicators

@main
struct HarbourApp: App {
	@Environment(\.scenePhase) var scenePhase
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared
	
	@State var isSettingsSheetPresented: Bool = false
	@State var isSetupSheetPresented: Bool = !Preferences.shared.finishedSetup
	@State var isContainerConsoleSheetPresented: Bool = false

	var body: some Scene {
		WindowGroup {
			ContentView(isSettingsSheetPresented: $isSettingsSheetPresented)
				.indicatorOverlay(model: appState.indicators)
				.sheet(isPresented: $isSettingsSheetPresented) {
					SettingsView()
						.environmentObject(portainer)
						.environmentObject(preferences)
				}
				.sheet(isPresented: $isSetupSheetPresented, onDismiss: { Preferences.shared.finishedSetup = true }) {
					SetupView()
				}
				.sheet(isPresented: $isContainerConsoleSheetPresented, onDismiss: onContainerConsoleViewDismissed) {
					ContainerConsoleView()
				}
				.onChange(of: scenePhase, perform: onScenePhaseChange)
				.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
				.onReceive(NotificationCenter.default.publisher(for: .ShowAttachedContainer, object: nil), perform: { _ in showAttachedContainer() })
				.defaultAppStorage(.group)
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
		}
	}
	
	private func onScenePhaseChange(_ scenePhase: ScenePhase) {
		switch scenePhase {
			case .active:
				Task {
					try? await portainer.getContainers()
				}
			case .background:
				if preferences.enableBackgroundRefresh {
					appState.scheduleBackgroundRefreshTask()
				}
			default:
				break
		}
	}
	
	private func onDeviceDidShake(_: Notification) {
		if portainer.attachedContainer != nil {
			showAttachedContainer()
		}
	}
	
	private func onContainerConsoleViewDismissed() {
		guard preferences.persistAttachedContainer else {
			portainer.attachedContainer = nil
			return
		}
		
		guard preferences.displayContainerDismissedPrompt && portainer.attachedContainer != nil else { return }
		
		let indicatorID: String = "ContainerDismissedIndicator"
		let indicator: Indicators.Indicator = .init(id: indicatorID, icon: "terminal.fill", headline: Localization.CONTAINER_DISMISSED_INDICATOR_TITLE.localized, subheadline: Localization.CONTAINER_DISMISSED_INDICATOR_DESCRIPTION.localized, dismissType: .after(5), onTap: {
			showAttachedContainer()
			appState.indicators.dismiss(matching: indicatorID)
		})
		appState.indicators.display(indicator)
	}
	
	private func showAttachedContainer() {
		guard portainer.attachedContainer != nil else {
			return
		}
		
		UIDevice.current.generateHaptic(.light)
		isContainerConsoleSheetPresented = true
	}
}

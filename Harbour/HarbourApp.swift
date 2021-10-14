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
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared
	
	@State private var isLegacyBuildPromptPresented: Bool = (UIDevice.current.systemVersion as NSString).floatValue >= 15
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.indicatorOverlay(model: appState.indicators)
				.sheet(isPresented: $isLegacyBuildPromptPresented) {
					VStack(spacing: 15) {
						Spacer()
						
						Text("This is a legacy build made only to support iOS 14, but you're running iOS >= 15!")
							.font(.title.weight(.bold))
						
						Text("You can continue using this version, but it won't receive any future updates.")
						
						Link(destination: URL(string: "https://github.com/rrroyal/Harbour/releases/latest")!) {
							Text("Visit GitHub to update - @rrroyal/Harbour")
						}
						.font(.body.weight(.semibold))
						
						Spacer()
						
						Text("Harbour v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
					.multilineTextAlignment(.center)
					.padding()
				}
				.sheet(isPresented: $appState.isContainerConsoleSheetPresented, onDismiss: onContainerConsoleViewDismissed) {
					ContainerConsoleView()
				}
				.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
				.defaultAppStorage(.group)
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
		}
	}
	
	private func onContainerConsoleViewDismissed() {
		guard preferences.persistAttachedContainer else {
			portainer.attachedContainer = nil
			return
		}
		
		guard preferences.displayContainerDismissedPrompt && portainer.attachedContainer != nil else { return }
		
		let indicatorID: String = "ContainerDismissedIndicator"
		let indicator: Indicators.Indicator = .init(id: indicatorID, icon: "terminal.fill", headline: Localization.CONTAINER_DISMISSED_INDICATOR_TITLE.localizedString, subheadline: Localization.CONTAINER_DISMISSED_INDICATOR_DESCRIPTION.localizedString, dismissType: .after(5), onTap: {
			UIDevice.current.generateHaptic(.light)
			appState.isContainerConsoleSheetPresented = true
			appState.indicators.dismiss(matching: indicatorID)
		})
		appState.indicators.display(indicator)
	}
	
	private func onDeviceDidShake(_: Notification) {
		guard portainer.attachedContainer != nil else { return }
		UIDevice.current.generateHaptic(.light)
		appState.isContainerConsoleSheetPresented = true
	}
}

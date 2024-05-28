//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CoreSpotlight
import IndicatorsKit
import Navigation
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
	@Environment(AppState.self) private var appState
	#if os(iOS)
	@Environment(SceneDelegate.self) private var sceneDelegate
	#elseif os(macOS)
	@State private var sceneDelegate = SceneDelegate()
	#endif
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.scenePhase) private var scenePhase

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate

		Group {
			#if os(iOS)
			ViewForIOS()
			#elseif os(macOS)
			ViewForMacOS()
			#endif
		}
		.animation(.smooth, value: portainerStore.isSetup)
		#if os(iOS)
		.indicatorOverlay(model: sceneDelegate.indicators, alignment: .top, insets: .init(top: 4, leading: 0, bottom: 0, trailing: 0))
		#elseif os(macOS)
		.indicatorOverlay(model: sceneDelegate.indicators, alignment: .topTrailing, insets: .init(top: 8, leading: 0, bottom: 0, trailing: 0))
		#endif
//		.alert(
//			sceneDelegate.activeAlert?.title ?? "",
//			isPresented: .constant(sceneDelegate.activeAlert != nil),
//			presenting: sceneDelegate.activeAlert
//		) { _ in
//			Button("Generic.OK") { }
//		} message: { details in
//			if let message = details.message {
//				Text(message)
//			}
//		}
		#if os(iOS)
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
		}
		#endif
		.sheet(isPresented: $sceneDelegate.isLandingSheetPresented) {
			sceneDelegate.onLandingDismissed()
		} content: {
			LandingView()
				#if os(macOS)
				.sheetMinimumFrame()
				#endif
		}
		.sheet(isPresented: $sceneDelegate.isContainerChangesSheetPresented) {
			NavigationStack {
				ContainerChangeView(changes: appState.lastContainerChanges ?? [])
					.addingCloseButton()
			}
			#if os(macOS)
			.sheetMinimumFrame()
			#endif
		}
		.sheet(isPresented: $sceneDelegate.isCreateStackSheetPresented) {
			sceneDelegate.editedStack = nil
			sceneDelegate.activeCreateStackSheetDetent = .medium
			sceneDelegate.handledCreateSheetDetentUpdate = false
		} content: {
			NavigationStack {
				CreateStackView(existingStack: sceneDelegate.editedStack, onEnvironmentEdit: { _ in
					guard !sceneDelegate.handledCreateSheetDetentUpdate else { return }
					sceneDelegate.activeCreateStackSheetDetent = .large
					sceneDelegate.handledCreateSheetDetentUpdate = true
				}, onStackFileSelection: { stackFileContent in
					guard !sceneDelegate.handledCreateSheetDetentUpdate else { return }

					if stackFileContent != nil {
						sceneDelegate.activeCreateStackSheetDetent = .large
					}

					sceneDelegate.handledCreateSheetDetentUpdate = true
				}, onStackCreation: { _ in
					portainerStore.refreshStacks()
					portainerStore.refreshContainers()
				})
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.addingCloseButton()
			}
			.presentationDetents([.medium, .large], selection: $sceneDelegate.activeCreateStackSheetDetent)
			.presentationDragIndicator(.hidden)
			.presentationContentInteraction(.resizes)
			#if os(macOS)
			.sheetMinimumFrame(width: 380, height: 400)
			#endif
		}
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails, perform: sceneDelegate.onContinueUserActivity)
		.onContinueUserActivity(HarbourUserActivityIdentifier.stackDetails, perform: sceneDelegate.onContinueUserActivity)
		.onContinueUserActivity(CSSearchableItemActionType, perform: sceneDelegate.onSpotlightUserActivity)
		.onChange(of: appState.notificationsToHandle, sceneDelegate.onNotificationsToHandleChange)
		.onChange(of: scenePhase, sceneDelegate.onScenePhaseChange)
		#if os(macOS)
		.environment(sceneDelegate)
		#endif
		.environment(\.errorHandler, .init(sceneDelegate.handleError))
		.environment(\.presentIndicator, .init(sceneDelegate.presentIndicator))
		.withNavigation(handler: sceneDelegate)
	}
}

// MARK: - Previews

#Preview {
	ContentView()
		.withEnvironment(appState: .shared)
		.environment(SceneDelegate())
}

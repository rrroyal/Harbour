//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import PortainerKit
import SwiftUI
import Indicators

struct ContentView: View {
	@EnvironmentObject var appState: AppState
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	
	@StateObject var sceneState: SceneState = SceneState()
	
	@State private var searchQuery: String = ""
		
	var currentState: ContentViewDataState {
		if portainer.containers.isEmpty {
			guard !appState.fetchingMainScreenData else {
				return .fetching
			}
			
			guard portainer.isLoggedIn || preferences.endpointURL != nil else {
				return .notLoggedIn
			}
			if portainer.selectedEndpointID != nil {
				return .noContainers
			} else {
				if portainer.endpoints.isEmpty {
					return .noEndpointsAvailable
				} else {
					return .noEndpointSelected
				}
			}
		} else {
			return .finished
		}
	}
	
	var toolbarMenu: some View {
		Menu(content: {
			if !portainer.endpoints.isEmpty {
				ForEach(portainer.endpoints) { endpoint in
					Button(action: {
						UIDevice.current.generateHaptic(.light)
						portainer.selectedEndpointID = endpoint.id
					}) {
						Text(endpoint.displayName)
						if portainer.selectedEndpointID == endpoint.id {
							Image(systemName: "checkmark")
						}
					}
				}
			} else {
				Text("No endpoints")
			}
			
			Divider()
			
			Button(action: {
				UIDevice.current.generateHaptic(.light)
				appState.fetchingMainScreenData = true
				Task {
					do {
						try await portainer.getEndpoints()
						try await portainer.getContainers()
						appState.fetchingMainScreenData = false
					} catch {
						sceneState.handle(error)
					}
				}
			}) {
				Label("Refresh", systemImage: "arrow.clockwise")
			}
		}) {
			Label(portainer.endpoints.first(where: { $0.id == portainer.selectedEndpointID })?.name ?? "Endpoint", systemImage: "tag")
				.symbolVariant(portainer.selectedEndpointID != nil ? .fill : (!portainer.endpoints.isEmpty ? .none : .slash))
		}
		.disabled(!portainer.isLoggedIn)
	}
	
	@ViewBuilder
	var content: some View {
		switch currentState {
			case .finished:
				ContainersView(containers: portainer.containers.filtered(query: searchQuery))
					.searchable(text: $searchQuery)
			default:
				Text(currentState.label ?? "")
					.foregroundStyle(.tertiary)
		}
	}
	
	var body: some View {
		NavigationView {
			content
				.navigationTitle("Harbour")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigation) {
						Button(action: {
							UIDevice.current.generateHaptic(.soft)
							sceneState.isSettingsSheetPresented = true
						}) {
							Image(systemName: "gear")
						}
					}
					
					ToolbarTitle(title: "Harbour", subtitle: appState.fetchingMainScreenData ? "Refreshing..." : nil)
					
					ToolbarItem(placement: .primaryAction, content: { toolbarMenu })
				}
			
			Text("Select container")
				.foregroundStyle(.tertiary)
		}
		.transition(.opacity)
		.animation(.easeInOut, value: portainer.isLoggedIn)
		.animation(.easeInOut, value: portainer.selectedEndpointID)
		.animation(.easeInOut, value: portainer.containers)
		.animation(.easeInOut, value: currentState)
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $sceneState.isContainerConsoleSheetPresented, onDismiss: sceneState.onContainerConsoleViewDismissed) {
			if let attachedContainer = portainer.attachedContainer {
				ContainerConsoleView(attachedContainer: attachedContainer)
			}
		}
		.sheet(isPresented: $sceneState.isSetupSheetPresented, onDismiss: { Preferences.shared.finishedSetup = true }) {
			SetupView()
		}
		.indicatorOverlay(model: sceneState.indicators)
		.onContinueUserActivity(AppState.UserActivity.viewingContainer, perform: handleContinueContainerViewingUserActivity)
		.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
		.environmentObject(sceneState)
		.environment(\.sceneErrorHandler, sceneErrorHandler)
	}
	
	private func handleContinueContainerViewingUserActivity(_ activity: NSUserActivity) {
		sceneState.logger.debug("Continuing UserActivity \"\(activity.activityType)\"")
		
		if let containerID = activity.userInfo?["ContainerID"] as? String {
			sceneState.activeContainerID = containerID
		}
	}
	
	private func onDeviceDidShake(notification: Notification) {
		if portainer.attachedContainer != nil {
			sceneState.showAttachedContainer()
		}
	}
	
	private func sceneErrorHandler(error: Error, indicator: Indicators.Indicator?, _fileID: StaticString = #fileID, _line: Int = #line) {
		if let indicator = indicator {
			sceneState.handle(error, indicator: indicator, _fileID: _fileID, _line: _line)
		} else {
			sceneState.handle(error, _fileID: _fileID, _line: _line)
		}
	}
}

extension ContentView {
	enum ContentViewDataState {
		case fetching
		case notLoggedIn
		case noEndpointSelected
		case noEndpointsAvailable
		case noContainers
		case finished
		
		var label: String? {
			switch self {
				case .fetching: return "Loading..."
				case .notLoggedIn: return "Not logged in"
				case .noEndpointSelected: return "No endpoint selected"
				case .noEndpointsAvailable: return "No endpoints available"
				case .noContainers: return "No containers"
				case .finished: return nil
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(Portainer.shared)
	}
}

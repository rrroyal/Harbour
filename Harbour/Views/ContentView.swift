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
	
	@StateObject private var sceneState: SceneState = SceneState()
	
	@State private var searchQuery: String = ""
		
	private var currentState: DataState {
		if portainer.containers.isEmpty {
			guard !(portainer.fetchingEndpoints || portainer.fetchingContainers) else {
				return .fetching
			}
			
			guard portainer.isReady else {
				return .notLoggedIn
			}
			if portainer.endpoints.isEmpty {
				return .noEndpointsAvailable
			} else {
				if portainer.selectedEndpointID != nil {
					return .noContainers
				}
				return .noEndpointSelected
			}
		} else {
			return .finished
		}
	}
	
	private var endpointButtonSymbolVariant: SymbolVariants {
		if portainer.isReady && !portainer.endpoints.isEmpty && portainer.selectedEndpointID != nil {
			return .fill
		}
		if !portainer.endpoints.isEmpty {
			return .none
		}
		return .slash
	}
	
	var toolbarMenu: some View {
		Menu(content: {
			if !portainer.endpoints.isEmpty {
				ForEach(portainer.endpoints) { endpoint in
					Button(action: {
						UIDevice.generateHaptic(.light)
						portainer.selectedEndpointID = endpoint.id
					}) {
						Text(endpoint.name ?? "\(endpoint.id)")
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
				UIDevice.generateHaptic(.light)
				Task {
					do {
						try await portainer.getEndpoints()
						try await portainer.getContainers()
					} catch {
						sceneState.handle(error)
					}
				}
			}) {
				Label("Refresh", systemImage: "arrow.clockwise")
			}
		}) {
			Label(portainer.endpoints.first(where: { $0.id == portainer.selectedEndpointID })?.name ?? "Endpoint", systemImage: "tag")
				.symbolVariant(endpointButtonSymbolVariant)
		}
		.disabled(!portainer.isReady)
	}
	
	@ViewBuilder
	var content: some View {
		switch currentState {
			case .finished:
				ContainersView(containers: portainer.containers.filtered(query: searchQuery))
					.searchable(text: $searchQuery)
			case .fetching:
				ProgressView()
			default:
				Text(currentState.label ?? "")
					.foregroundStyle(.tertiary)
					.id(currentState)
		}
	}
	
	var body: some View {
		NavigationView {
			content
				.transition(.opacity)
				.navigationTitle("Harbour")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigation) {
						Button(action: {
							UIDevice.generateHaptic(.soft)
							sceneState.isSettingsSheetPresented = true
						}) {
							Image(systemName: "gear")
						}
					}
					
					ToolbarTitle(title: "Harbour", subtitle: (portainer.fetchingEndpoints || portainer.fetchingContainers) ? "Refreshing..." : nil)
					
					ToolbarItem(placement: .primaryAction, content: { toolbarMenu })
				}
			
			Text("Select container")
				.foregroundStyle(.tertiary)
		}
		.transition(.opacity)
		.animation(.easeInOut, value: portainer.isReady)
		.animation(.easeInOut, value: portainer.selectedEndpointID)
		.animation(.easeInOut, value: portainer.containers)
		.animation(.easeInOut, value: currentState)
		.navigationViewStyle(useColumns: preferences.clUseColumns)
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $sceneState.isContainerConsoleSheetPresented, onDismiss: {
			DispatchQueue.main.async {
				sceneState.onContainerConsoleViewDismissed()
			}
		}) {
			if let attachedContainer = portainer.attachedContainer {
				ContainerConsoleView(attachedContainer: attachedContainer)
			}
		}
		.sheet(isPresented: $sceneState.isSetupSheetPresented, onDismiss: { Preferences.shared.finishedSetup = true }) {
			SetupView()
		}
		.indicatorOverlay(model: sceneState.indicators)
		.onContinueUserActivity(AppState.UserActivity.viewingContainer) { activity in
			DispatchQueue.main.async {
				sceneState.handleContinueUserActivity(activity)
			}
		}
		.onContinueUserActivity(AppState.UserActivity.attachedToContainer) { activity in
			DispatchQueue.main.async {
				sceneState.handleContinueUserActivity(activity)
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
		.environmentObject(sceneState)
		.environment(\.sceneErrorHandler, sceneErrorHandler)
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

private extension ContentView {
	enum DataState {
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

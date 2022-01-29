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
		guard !(portainer.fetchingEndpoints || portainer.fetchingContainers) else { return .fetching }
		guard portainer.isSetup && portainer.isLoggedIn else { return .notLoggedIn }
		guard !portainer.endpoints.isEmpty else { return .noEndpointsAvailable }
		guard portainer.selectedEndpointID != nil else { return .noEndpointSelected }
		guard !portainer.containers.isEmpty else { return .noContainers }
		return .finished
	}
	
	private var endpointButtonSymbolVariant: SymbolVariants {
		guard portainer.isSetup && portainer.isLoggedIn else { return .slash }
		if !portainer.endpoints.isEmpty && portainer.selectedEndpointID != nil { return .fill }
		if !portainer.endpoints.isEmpty { return .none }
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
		.disabled(!portainer.isSetup)
	}
	
	@ViewBuilder
	var content: some View {
		if portainer.containers.isEmpty {
			switch currentState {
				case .fetching:
					ProgressView()
				default:
					Text(currentState.label)
						.foregroundStyle(.tertiary)
						.id(currentState)
			}
		} else {
			ContainersView(containers: portainer.containers.filtered(query: searchQuery).groupedByStack())
				.equatable()
				.searchable(text: $searchQuery)
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
		.animation(.easeInOut, value: portainer.isSetup)
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
		.onContinueUserActivity(AppState.UserActivity.viewContainer, perform: handleContinueUserActivity)
		.onContinueUserActivity(AppState.UserActivity.attachToContainer, perform: handleContinueUserActivity)
		.onOpenURL(perform: onOpenURL)
		.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
		.environmentObject(sceneState)
		.environment(\.sceneErrorHandler, sceneErrorHandler)
	}
	
	private func onOpenURL(_ url: URL) {
		sceneState.onOpenURL(url)
	}
	
	private func handleContinueUserActivity(_ activity: NSUserActivity) {
		DispatchQueue.main.async {
			sceneState.handleContinueUserActivity(activity)
		}
	}
	
	private func onDeviceDidShake(_ notification: Notification) {
		guard portainer.attachedContainer != nil else { return }
		sceneState.showAttachedContainer()
	}
	
	private func sceneErrorHandler(error: Error, indicator: Indicators.Indicator?, _fileID: StaticString = #fileID, _line: Int = #line, _function: StaticString = #function) {
		if let indicator = indicator {
			sceneState.handle(error, indicator: indicator, _fileID: _fileID, _line: _line, _function: _function)
		} else {
			sceneState.handle(error, _fileID: _fileID, _line: _line, _function: _function)
		}
	}
}

private extension ContentView {
	enum DataState {
		case finished
		case fetching
		case notLoggedIn
		case noEndpointSelected
		case noEndpointsAvailable
		case noContainers
		
		var label: String {
			switch self {
				case .fetching: return "Loading..."
				case .notLoggedIn: return "Not logged in"
				case .noEndpointSelected: return "No endpoint selected"
				case .noEndpointsAvailable: return "No endpoints available"
				case .noContainers: return "No containers"
				case .finished: return "Finished! If you see this, please let me know on Twitter - @destroystokyo 😶"
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

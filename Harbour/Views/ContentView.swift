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
		
	@State private var isSettingsSheetPresented: Bool = false
	@State private var isSetupSheetPresented: Bool = !Preferences.shared.finishedSetup
	@State private var isContainerConsoleSheetPresented: Bool = false
	
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
						AppState.shared.handle(error)
					}
				}
			}) {
				Label("Refresh", systemImage: "arrow.clockwise")
			}
		}) {
			Image(systemName: "tag")
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
							isSettingsSheetPresented = true
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
		.onAppear {
			if !portainer.isLoggedIn {
				appState.fetchingMainScreenData = preferences.endpointURL != nil
			}
		}
		.indicatorOverlay(model: appState.indicators)
		.sheet(isPresented: $isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $isContainerConsoleSheetPresented, onDismiss: appState.onContainerConsoleViewDismissed) {
			if let attachedContainer = portainer.attachedContainer {
				ContainerConsoleView(attachedContainer: attachedContainer)
			}
		}
		.sheet(isPresented: $isSetupSheetPresented, onDismiss: { Preferences.shared.finishedSetup = true }) {
			SetupView()
		}
		.onReceive(NotificationCenter.default.publisher(for: .ShowAttachedContainer, object: nil), perform: { _ in isContainerConsoleSheetPresented = true })
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

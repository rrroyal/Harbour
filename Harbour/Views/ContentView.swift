//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import PortainerKit
import SwiftUI

struct ContentView: View {
	@EnvironmentObject var appState: AppState
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	@Binding var isSettingsSheetPresented: Bool
	
	@State private var searchQuery: String = ""
	
	var currentState: ContentViewDataState {
		guard !appState.fetchingMainScreenData else {
			return .fetching
		}
		
		guard portainer.isLoggedIn || preferences.endpointURL != nil else {
			return .notLoggedIn
		}
		
		if portainer.endpoints.isEmpty {
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
					} catch {
						AppState.shared.handle(error)
					}
				}
				appState.fetchingMainScreenData = false
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
				Group {
					if preferences.useGridView {
						ContainerGridView(containers: portainer.containers.filtered(query: searchQuery))
					} else {
						ContainerListView(containers: portainer.containers.filtered(query: searchQuery))
					}
				}
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
		ContentView(isSettingsSheetPresented: .constant(false))
			.environmentObject(Portainer.shared)
	}
}

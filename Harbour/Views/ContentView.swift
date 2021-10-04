//
//  ContentView.swift
//  Harbour
//
//  Created by unitears on 10/06/2021.
//

import PortainerKit
import SwiftUI

struct ContentView: View {
	@EnvironmentObject var appState: AppState
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	
	@State private var searchQuery: String = ""
	@State private var isSettingsSheetPresented: Bool = false
	
	var toolbarMenu: some View {
		Menu(content: {
			if !portainer.endpoints.isEmpty {
				ForEach(portainer.endpoints) { endpoint in
					Button(action: {
						UIDevice.current.generateHaptic(.light)
						portainer.selectedEndpoint = endpoint
					}) {
						Text(endpoint.displayName)
						if portainer.selectedEndpoint?.id == endpoint.id {
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
				.symbolVariant(portainer.selectedEndpoint != nil ? .fill : (!portainer.endpoints.isEmpty ? .none : .slash))
		}
		.disabled(!portainer.isLoggedIn)
	}
	
	var emptyDisclaimer: some View {
		Group {
			if portainer.isLoggedIn {
				if portainer.selectedEndpoint != nil {
					if portainer.containers.isEmpty {
						Text("No containers")
					}
				} else {
					Text("Select endpoint")
				}
			} else {
				Text("Not logged in")
			}
		}
		.opacity(Globals.Views.secondaryOpacity)
		.transition(.opacity)
		.animation(.easeInOut, value: portainer.isLoggedIn)
		.animation(.easeInOut, value: portainer.containers.isEmpty)
		// .hidden(portainer.isLoggedIn && !portainer.containers.isEmpty)
	}
	
	var body: some View {
		NavigationView {
			Group {
				if preferences.useGridView {
					ContainerGridView(containers: portainer.containers.filtered(query: searchQuery))
				} else {
					ContainerListView(containers: portainer.containers.filtered(query: searchQuery))
				}
			}
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
			.background(emptyDisclaimer)
			.refreshable {
				if let endpointID = portainer.selectedEndpoint?.id {
					appState.fetchingMainScreenData = true

					do {
						try await portainer.getContainers(endpointID: endpointID)
					} catch {
						AppState.shared.handle(error)
					}
					
					appState.fetchingMainScreenData = false
				}
			}
			.searchable(text: $searchQuery)
		}
		.sheet(isPresented: $isSettingsSheetPresented) {
			SettingsView()
				.environmentObject(portainer)
				.environmentObject(preferences)
		}
		/* .onAppear {
		 	if let endpointID = portainer.selectedEndpoint?.id {
		 		await portainer.getContainers(endpointID: endpointID)
		 	}
		 } */
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(Portainer.shared)
	}
}

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
	
	@State private var loading: Bool = false
	@State private var isSettingsSheetPresented: Bool = false
	
	let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
	
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
				loading = true
				Task {
					do {
						try await portainer.getEndpoints()
					} catch {
						AppState.shared.handle(error)
					}
				}
				loading = false
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
			ScrollView {
				LazyVGrid(columns: columns) {
					ForEach(portainer.containers) { container in
						NavigationLink(destination: ContainerDetailView(container: container)) {
							ContainerCell(container: container)
								.contextMenu {
									ContainerContextMenu(container: container)
								}
						}
						.buttonStyle(DecreasesOnPressButtonStyle())
					}
				}
				.padding()
				.animation(.easeInOut, value: portainer.containers)
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
				
				ToolbarTitle(title: "Harbour", subtitle: loading ? "Refreshing..." : nil)
				
				ToolbarItem(placement: .primaryAction, content: { toolbarMenu })
			}
			.background(emptyDisclaimer)
			.refreshable {
				if let endpointID = portainer.selectedEndpoint?.id {
					loading = true

					do {
						try await portainer.getContainers(endpointID: endpointID)
					} catch {
						AppState.shared.handle(error)
					}
					
					loading = false
				}
			}
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

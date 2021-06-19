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
	
	let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
	
	var body: some View {
		NavigationView {
			ScrollView {
				LazyVGrid(columns: columns) {
					ForEach(portainer.containers) { container in
						NavigationLink(destination: ContainerDetailView(container: container)) {
							ContainerCell(container: container)
						}
						.buttonStyle(DecreasesOnPressButtonStyle())
						/* .contextMenu {
						 	ContainerContextMenu(container: container)
						 } */
					}
				}
				.padding(.horizontal)
				// .transition(.opacity)
				.animation(.easeInOut, value: portainer.containers)
			}
			.navigationTitle(Text("Harbour"))
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button(action: {
						appState.isSettingsViewPresented = true
					}) {
						Image(systemName: "gear")
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Menu(portainer.selectedEndpoint?.displayName ?? "Endpoint") {
						if !portainer.endpoints.isEmpty {
							ForEach(portainer.endpoints) { endpoint in
								Button(action: {
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
						
						Button(role: nil, action: {
							await portainer.getEndpoints()
						}) {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
					.disabled(!portainer.isLoggedIn)
				}
			}
			.refreshable {
				if let endpointID = portainer.selectedEndpoint?.id {
					await portainer.getContainers(endpointID: endpointID)
				}
			}
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

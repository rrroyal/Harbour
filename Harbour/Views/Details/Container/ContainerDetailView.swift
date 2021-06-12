//
//  ContainerDetailView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerDetailView: View {
	@EnvironmentObject var portainer: Portainer

	let container: PortainerKit.Container
	
	@State var isLoading: Bool = true
	@State var containerDetails: PortainerKit.ContainerDetails? = nil
		
	var buttonsSection: some View {
		LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
			NavigationLink(destination: ContainerMountsDetailsView(container: container)) {
				NavigationLinkLabel(label: "Mounts", symbolName: "externaldrive.fill")
			}
			.buttonStyle(DecreasesOnPressButtonStyle())
			
			NavigationLink(destination: ContainerNetworkDetailsView(container: container)) {
				NavigationLinkLabel(label: "Network", symbolName: "network")
			}
			.buttonStyle(DecreasesOnPressButtonStyle())
			
			NavigationLink(destination: ContainerHostConfigDetailsView(container: container)) {
				NavigationLinkLabel(label: "Host", symbolName: "server.rack")
			}
			.buttonStyle(DecreasesOnPressButtonStyle())
			
			NavigationLink(destination: ContainerLogsView(container: container)) {
				NavigationLinkLabel(label: "Logs", symbolName: "text.alignleft")
			}
			.buttonStyle(DecreasesOnPressButtonStyle())
		}
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 15) {
				buttonsSection
					.padding(.horizontal)
			}
		}
		.background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
		.overlay(
			ZStack {
				Color(uiColor: .systemBackground)
					.opacity(1 - Globals.Views.secondaryOpacity)
				ProgressView()
			}
			.allowsHitTesting(isLoading)
			.edgesIgnoringSafeArea(.all)
			.hidden(!isLoading)
		)
		.navigationTitle(container.displayName ?? container.id)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Menu(content: {
					ContainerContextMenu(container: container)
				}, label: {
					Image(systemName: container.stateSymbol)
				})
					.animation(.easeInOut, value: container.state)
					.transition(.opacity)
			}
		}
		.refreshable {
			await refresh()
		}
		.task {
			self.isLoading = true
			await refresh()
			self.isLoading = false
		}
		.onReceive(portainer.refreshCurrentContainer) {
			async { await refresh() }
		}
	}
	
	private func refresh() async {
		let result = await portainer.inspectContainer(container)
		switch result {
			case .success(let containerDetails):
				self.containerDetails = containerDetails
				self.container.state = containerDetails.state.status
			case .failure(let error):
				AppState.shared.handle(error)
		}
	}
}

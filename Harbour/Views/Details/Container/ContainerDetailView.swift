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
			NavigationLink(destination: ContainerMountsDetailsView(container: container, details: containerDetails)) {
				NavigationLinkLabel(label: "Mounts", symbolName: "externaldrive.fill")
			}
			.buttonStyle(DecreasesOnPressButtonStyle())
			
			NavigationLink(destination: ContainerNetworkDetailsView(container: container, details: containerDetails)) {
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
	
	var loadingOverlay: some View {
		ZStack {
			Color(uiColor: .systemBackground)
				.opacity(1 - Globals.Views.secondaryOpacity)
			ProgressView()
		}
		.allowsHitTesting(isLoading)
		.edgesIgnoringSafeArea(.all)
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 10) {
				buttonsSection
				
				if let containerDetails = containerDetails {
					GeneralSection(details: containerDetails)
					StateSection(state: containerDetails.state)
					ConfigSection(config: containerDetails.config)
					HostConfigSection(hostConfig: containerDetails.hostConfig)
					GraphDriverSection(graphDriver: containerDetails.graphDriver)
				}
			}
			.padding(.horizontal)
		}
		.background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
		.overlay(loadingOverlay.hidden(!isLoading))
		.navigationTitle(container.displayName ?? container.id)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Menu(content: {
					ContainerContextMenu(container: container)
				}) {
					Image(systemName: container.stateSymbol)
				}
				// .animation(.easeInOut, value: container.state)
				// .transition(.opacity)
			}
		}
		.refreshable(action: refresh)
		.task {
			self.isLoading = true
			await refresh()
			self.isLoading = false
		}
		.onReceive(portainer.refreshCurrentContainer) {
			async {
				self.isLoading = true
				await refresh()
				self.isLoading = false
			}
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

fileprivate extension ContainerDetailView {
	struct DisclosureSection<Content>: View where Content: View {
		let label: String
		@ViewBuilder let content: () -> Content
		
		@State var isExpanded: Bool = true
		
		var body: some View {
			DisclosureGroup(isExpanded: $isExpanded, content: {
				VStack(spacing: 20, content: content)
			}) {
				Text(LocalizedStringKey(label))
					.padding(.vertical, .medium)
			}
		}
	}
	
	struct GeneralSection: View {
		let details: PortainerKit.ContainerDetails
		
		var body: some View {
			DisclosureSection(label: "General") {
				Group {
					LabeledSection(label: "ID", content: details.id)
					LabeledSection(label: "Name", content: details.name)
					LabeledSection(label: "Image", content: details.image)
					LabeledSection(label: "Path", content: details.path)
					LabeledSection(label: "Arguments", content: !details.args.isEmpty ? details.args.joined(separator: ", ") : nil)
					LabeledSection(label: "Created", content: details.created.formatted(), monospace: false)
				}
				
				Group {
					LabeledSection(label: "Mount label", content: details.mountLabel)
					LabeledSection(label: "Process label", content: details.processLabel)
				}
				
				Group {
					LabeledSection(label: "Restart count", content: "\(details.restartCount)", monospace: false)
					LabeledSection(label: "Driver", content: details.driver)
					LabeledSection(label: "App armor profile", content: details.appArmorProfile)
					LabeledSection(label: "Size RW", content: details.sizeRW != nil ? "\(details.sizeRW ?? 0)" : nil)
					LabeledSection(label: "Size RootFS", content: details.sizeRootFS != nil ? "\(details.sizeRootFS ?? 0)" : nil)
				}
				
				Group {
					LabeledSection(label: "resolv.conf path", content: details.resolvConfPath)
					LabeledSection(label: "Hostname path", content: details.hostnamePath)
					LabeledSection(label: "Hosts path", content: details.hostsPath)
					LabeledSection(label: "Log path", content: details.logPath)
				}
			}
		}
	}
	
	struct StateSection: View {
		let state: PortainerKit.ContainerState

		var body: some View {
			DisclosureSection(label: "State") {
				LabeledSection(label: "Status", content: state.status.rawValue)
				LabeledSection(label: "PID", content: "\(state.pid)")
				LabeledSection(label: "Running", content: "\(state.running)")
				LabeledSection(label: "Paused", content: "\(state.paused)")
				LabeledSection(label: "Restarting", content: "\(state.restarting)")
				LabeledSection(label: "OOM Killed", content: "\(state.oomKilled)")
				LabeledSection(label: "Dead", content: "\(state.dead)")
				LabeledSection(label: "Error", content: state.error)
				LabeledSection(label: "Started at", content: state.startedAt?.formatted())
				LabeledSection(label: "Finished at", content: state.finishedAt?.formatted())
			}
		}
	}
	
	struct ConfigSection: View {
		let config: PortainerKit.ContainerConfig
		
		var body: some View {
			DisclosureSection(label: "Config") {
			}
		}
	}

	struct HostConfigSection: View {
		let hostConfig: PortainerKit.HostConfig

		var body: some View {
			DisclosureSection(label: "Host") {
			}
		}
	}

	struct GraphDriverSection: View {
		let graphDriver: PortainerKit.GraphDriver

		var body: some View {
			DisclosureSection(label: "GraphDriver") {
			}
		}
	}
}

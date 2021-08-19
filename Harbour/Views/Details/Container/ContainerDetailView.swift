//
//  ContainerDetailView.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerDetailView: View {
	@EnvironmentObject var portainer: Portainer
	@ObservedObject var container: PortainerKit.Container
	
	@State private var isLoading: Bool = false
	@State private var containerDetails: PortainerKit.ContainerDetails? = nil
		
	var buttonsSection: some View {
		LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
			NavigationLink(destination: ContainerMountsDetailsView(mounts: container.mounts, details: containerDetails?.mounts)) {
				NavigationLinkLabel(label: "Mounts", symbolName: "externaldrive.fill")
			}
			
			NavigationLink(destination: ContainerNetworkDetailsView(networkSettings: container.networkSettings, details: containerDetails?.networkSettings, ports: container.ports)) {
				NavigationLinkLabel(label: "Network", symbolName: "network")
			}
			
			NavigationLink(destination: ContainerConfigDetailsView(config: containerDetails?.config, hostConfig: containerDetails?.hostConfig ?? container.hostConfig)) {
				NavigationLinkLabel(label: "Config", symbolName: "server.rack")
			}
			
			NavigationLink(destination: ContainerLogsView(container: container)) {
				NavigationLinkLabel(label: "Logs", symbolName: "text.alignleft")
			}
		}
		.buttonStyle(DecreasesOnPressButtonStyle())
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 10) {
				buttonsSection
				
				if let containerDetails = containerDetails {
					GeneralSection(details: containerDetails)
					StateSection(state: containerDetails.state)
					GraphDriverSection(graphDriver: containerDetails.graphDriver)
				}
			}
			.padding()
		}
		.background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
		.navigationTitle(container.displayName ?? container.id)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: container.displayName ?? container.id, subtitle: isLoading ? "Refreshing..." : nil)
			
			ToolbarItem(placement: .primaryAction) {
				Menu(content: {
					ContainerContextMenu(container: container)
					
					Divider()
					
					Button(action: {
						UIDevice.current.generateHaptic(.light)
						Task {
							await refresh()
						}
					}) {
						Label("Refresh", systemImage: "arrow.clockwise")
					}
				}) {
					Image(systemName: container.stateSymbol)
						.accentColor(container.stateColor)
						.animation(.easeInOut, value: container.state)
						.transition(.opacity)
				}
			}
		}
		.refreshable { await refresh() }
		.task { await refresh() }
		.onReceive(portainer.refreshCurrentContainer) {
			Task { await refresh() }
		}
	}
	
	private func refresh() async {
		isLoading = true
		
		do {
			let containerDetails = try await portainer.inspectContainer(container)
			withAnimation {
				self.containerDetails = containerDetails
				container.update(from: containerDetails)
			}
		} catch {
			AppState.shared.handle(error)
		}
		
		isLoading = false
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
					LabeledSection(label: "ID", content: details.id, monospace: true)
					LabeledSection(label: "Name", content: details.name, monospace: true)
					LabeledSection(label: "Image", content: details.image, monospace: true)
					LabeledSection(label: "Platform", content: details.platform, monospace: true)
					LabeledSection(label: "Path", content: details.path, monospace: true)
					LabeledSection(label: "Arguments", content: !details.args.isEmpty ? details.args.joined(separator: ", ") : nil, monospace: true)
					LabeledSection(label: "Created", content: details.created.formatted())
				}
				
				Group {
					LabeledSection(label: "Mount label", content: details.mountLabel, monospace: true)
					LabeledSection(label: "Process label", content: details.processLabel, monospace: true)
				}
				
				Group {
					LabeledSection(label: "Restart count", content: "\(details.restartCount)", monospace: true)
					LabeledSection(label: "Driver", content: details.driver, monospace: true)
					LabeledSection(label: "App armor profile", content: details.appArmorProfile, monospace: true)
					LabeledSection(label: "RW size", content: details.sizeRW != nil ? "\(details.sizeRW ?? 0)" : nil, monospace: true)
					LabeledSection(label: "RootFS size", content: details.sizeRootFS != nil ? "\(details.sizeRootFS ?? 0)" : nil, monospace: true)
				}
				
				Group {
					LabeledSection(label: "resolv.conf path", content: details.resolvConfPath, monospace: true)
					LabeledSection(label: "Hostname path", content: details.hostnamePath, monospace: true)
					LabeledSection(label: "Hosts path", content: details.hostsPath, monospace: true)
					LabeledSection(label: "Log path", content: details.logPath, monospace: true)
				}
			}
		}
	}
	
	struct StateSection: View {
		let state: PortainerKit.ContainerState

		var body: some View {
			DisclosureSection(label: "State") {
				LabeledSection(label: "Status", content: state.status.rawValue, monospace: true)
				LabeledSection(label: "PID", content: "\(state.pid)", monospace: true)
				LabeledSection(label: "Running", content: "\(state.running)", monospace: true)
				LabeledSection(label: "Paused", content: "\(state.paused)", monospace: true)
				LabeledSection(label: "Restarting", content: "\(state.restarting)", monospace: true)
				LabeledSection(label: "OOM Killed", content: "\(state.oomKilled)", monospace: true)
				LabeledSection(label: "Dead", content: "\(state.dead)", monospace: true)
				LabeledSection(label: "Error", content: state.error, monospace: true)
				LabeledSection(label: "Started at", content: state.startedAt?.formatted())
				LabeledSection(label: "Finished at", content: state.finishedAt?.formatted())
			}
		}
	}

	struct GraphDriverSection: View {
		let graphDriver: PortainerKit.GraphDriver

		var body: some View {
			DisclosureSection(label: "GraphDriver") {
				LabeledSection(label: "Name", content: graphDriver.name, monospace: true)
				LabeledSection(label: "Lower dir", content: graphDriver.data.lowerDir, monospace: true)
				LabeledSection(label: "Merged dir", content: graphDriver.data.mergedDir, monospace: true)
				LabeledSection(label: "Upper dir", content: graphDriver.data.upperDir, monospace: true)
				LabeledSection(label: "Work dir", content: graphDriver.data.workDir, monospace: true)
			}
		}
	}
}

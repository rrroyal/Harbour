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
	
	@State private var loading: Bool = false
	
	@State private var lastLogsSnippet: String? = nil
	
	let lastLogsTailCount: Int = 5
		
	var buttonsSection: some View {
		LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
			NavigationLink(destination: ContainerMountsDetailsView(mounts: container.mounts, details: container.details?.mounts)) {
				NavigationLinkLabel(label: "Mounts", symbolName: "externaldrive.fill")
			}
			
			NavigationLink(destination: ContainerNetworkDetailsView(networkSettings: container.networkSettings, details: container.details?.networkSettings, ports: container.ports)) {
				NavigationLinkLabel(label: "Network", symbolName: "network")
			}
			
			NavigationLink(destination: ContainerConfigDetailsView(config: container.details?.config, hostConfig: container.details?.hostConfig ?? container.hostConfig)) {
				NavigationLinkLabel(label: "Config", symbolName: "server.rack")
			}
			
			NavigationLink(destination: ContainerLogsView(container: container)) {
				NavigationLinkLabel(label: "Logs", symbolName: "text.alignleft")
			}
		}
		.buttonStyle(DecreasesOnPressButtonStyle())
	}
	
	@ViewBuilder
	var generalSection: some View {
		if let details = container.details {
			LabeledSection(label: "ID", content: details.id, monospace: true)
			LabeledSection(label: "Created", content: details.created.formatted())
			LabeledSection(label: "PID", content: "\(details.state.pid)", monospace: true)
			LabeledSection(label: "Status", content: container.status ?? details.state.status.rawValue, monospace: true)
			LabeledSection(label: "Error", content: details.state.error, monospace: true)
			LabeledSection(label: "Started at", content: details.state.startedAt?.formatted())
			LabeledSection(label: "Finished at", content: details.state.finishedAt?.formatted())
		} else {
			ProgressView()
				.padding()
				.frame(maxWidth: .infinity, alignment: .center)
		}
	}
	
	var logsSection: some View {
		CustomSection(label: "Logs (last \(lastLogsTailCount) lines)") {
			if let logs = lastLogsSnippet {
				Text(logs)
					.font(.system(.footnote, design: .monospaced))
					.lineLimit(nil)
					.contentShape(Rectangle())
					.frame(maxWidth: .infinity, alignment: .topLeading)
					.textSelection(.enabled)
			} else {
				ProgressView()
					.padding()
					.frame(maxWidth: .infinity, alignment: .center)
			}
		}
		.transition(.opacity)
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 20) {
				buttonsSection
				generalSection
				logsSection
				
				if let containerDetails = container.details {
					GeneralSection(details: containerDetails)
					StateSection(state: containerDetails.state)
					GraphDriverSection(graphDriver: containerDetails.graphDriver)
				}
			}
			.padding()
		}
		.background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
		.animation(.easeInOut, value: lastLogsSnippet)
		.animation(.easeInOut, value: container.details)
		.navigationTitle(container.displayName ?? container.id)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: container.displayName ?? container.id, subtitle: loading ? "Refreshing..." : nil)
			
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
					Image(systemName: container.state.icon)
						.accentColor(container.state.color)
						.animation(.easeInOut, value: container.state)
						.transition(.opacity)
				}
			}
		}
		.refreshable { await refresh() }
		.task { await refresh() }
		.onReceive(portainer.refreshCurrentContainerPassthroughSubject) {
			Task { await refresh() }
		}
	}
	
	private func refresh() async {
		loading = true
		
		Task {
			do {
				let logs = try await portainer.getLogs(from: container, tail: lastLogsTailCount, displayTimestamps: true)
				self.lastLogsSnippet = logs.trimmingCharacters(in: .whitespacesAndNewlines)
			} catch {
				self.lastLogsSnippet = error.localizedDescription
			}
		}
		
		do {
			let containerDetails = try await portainer.inspectContainer(container)
			withAnimation {
				container.update(from: containerDetails)
			}
		} catch {
			AppState.shared.handle(error)
		}
		
		loading = false
	}
}

fileprivate extension ContainerDetailView {
	struct DisclosureSection<Content>: View where Content: View {
		let label: String
		@ViewBuilder let content: () -> Content
				
		var body: some View {
			DisclosureGroup(content: {
				VStack(spacing: 20, content: content)
					.padding(.top, .medium)
			}) {
				Text(LocalizedStringKey(label))
			}
		}
	}
	
	struct GeneralSection: View {
		let details: PortainerKit.ContainerDetails
		
		var body: some View {
			DisclosureSection(label: "General") {
				Group {
					LabeledSection(label: "Name", content: details.name, monospace: true)
					LabeledSection(label: "Image", content: details.image, monospace: true)
					LabeledSection(label: "Platform", content: details.platform, monospace: true)
					LabeledSection(label: "Path", content: details.path, monospace: true)
					LabeledSection(label: "Arguments", content: !details.args.isEmpty ? details.args.joined(separator: ", ") : nil, monospace: true)
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
				LabeledSection(label: "State", content: state.status.rawValue, monospace: true)
				LabeledSection(label: "Running", content: "\(state.running)", monospace: true)
				LabeledSection(label: "Paused", content: "\(state.paused)", monospace: true)
				LabeledSection(label: "Restarting", content: "\(state.restarting)", monospace: true)
				LabeledSection(label: "OOM Killed", content: "\(state.oomKilled)", monospace: true)
				LabeledSection(label: "Dead", content: "\(state.dead)", monospace: true)
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

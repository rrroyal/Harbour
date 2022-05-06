//
//  ContainerDetailView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

// TODO: Rework this view

import PortainerKit
import SwiftUI

struct ContainerDetailView: View {
	@EnvironmentObject var sceneState: SceneState
	@EnvironmentObject var portainer: Portainer
	@ObservedObject var container: PortainerKit.Container
		
	@State private var loading: Bool = false
	@State private var lastLogsSnippet: String? = nil
		
	let lastLogsTailCount: Int = 5
		
	var buttonsSection: some View {
		LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
			NavigationLink(destination: ContainerMountsDetailsView(mounts: container.mounts, details: container.details?.mounts)) {
				NavigationLinkLabel(label: Localization.Docker.Container.mounts, symbolName: "externaldrive.fill")
			}
			
			NavigationLink(destination: ContainerNetworkDetailsView(networkSettings: container.networkSettings, details: container.details?.networkSettings, ports: container.ports)) {
				NavigationLinkLabel(label: Localization.Docker.Container.network, symbolName: "network")
			}
			
			NavigationLink(destination: ContainerConfigDetailsView(config: container.details?.config, hostConfig: container.details?.hostConfig ?? container.hostConfig)) {
				NavigationLinkLabel(label: Localization.Docker.Container.config, symbolName: "server.rack")
			}
			
			NavigationLink(destination: ContainerLogsView(container: container)) {
				NavigationLinkLabel(label: Localization.Docker.Container.logs, symbolName: "text.alignleft")
			}
		}
		.buttonStyle(.decreasesOnPress)
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 20) {
				buttonsSection

				if let details = container.details {
					GeneralSection(container: container, details: details)
				}

				if let lastLogsSnippet = lastLogsSnippet {
					LogsSection(logs: lastLogsSnippet, tailCount: lastLogsTailCount)
				}

				if let details = container.details {
					DetailsSection(details: details)
					StateSection(state: details.state)
					GraphDriverSection(graphDriver: details.graphDriver)
				}
			}
			.padding()
		}
		.background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
		.navigationTitle(container.displayName ?? container.id)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: container.displayName ?? container.id, subtitle: loading ? Localization.Generic.fetching : nil)
			
			ToolbarItem(placement: .primaryAction) {
				Menu(content: {
					ContainerContextMenu(container: container)
					
					Divider()
					
					Button(action: {
						UIDevice.generateHaptic(.light)
						Task {
							await refresh()
						}
					}) {
						Label(Localization.Generic.refresh, systemImage: "arrow.clockwise")
					}
				}) {
					Image(systemName: container.state.icon)
						.accentColor(container.state.color)
						.animation(.easeInOut, value: container.state)
						.transition(.opacity)
				}
			}
		}
		.animation(.easeInOut, value: loading)
		.animation(.easeInOut, value: container.details != nil)
		.animation(.easeInOut, value: lastLogsSnippet != nil)
		.refreshable { await refresh() }
		.task { await refresh() }
		.userActivity(UserActivity.ViewContainer.activityType, isActive: sceneState.activeContainer == container) { activity in
			activity.requiredUserInfoKeys = UserActivity.ViewContainer.requiredUserInfoKeys
			activity.userInfo = [
				UserActivity.UserInfoKey.containerID: container.id,
				UserActivity.UserInfoKey.endpointID: portainer.selectedEndpointID as Any
			]
			activity.title = Localization.UserActivity.ViewContainer.title(container.displayName ?? container.id)
			activity.suggestedInvocationPhrase = activity.title
			activity.persistentIdentifier = "\(activity.activityType):\(container.id)"
			activity.isEligibleForPrediction = true
			activity.isEligibleForHandoff = true
			activity.isEligibleForSearch = true
		}
		#warning("TODO: Fix portainer.refreshContainerPassthroughSubject (retains view)")
		/* .onReceive(portainer.refreshContainerPassthroughSubject) { containerID in
			#warning("Gets called even though it's not focused")
			if containerID == container.id {
				Task { await refresh() }
			}
		} */
	}
	
	private func refresh() async {
		loading = true
		defer { loading = false }
		
		do {
			async let logs = portainer.getLogs(from: container.id, tail: lastLogsTailCount, displayTimestamps: true)
			async let containerDetails = portainer.inspectContainer(container)
			let result = (logs: try await logs, details: try await containerDetails)
			
			DispatchQueue.main.async {
				withAnimation {
					self.lastLogsSnippet = result.logs.trimmingCharacters(in: .whitespacesAndNewlines)
					container.update(from: result.details)
				}
			}
		} catch {
			sceneState.handle(error)
		}
	}
}

extension ContainerDetailView: Identifiable, Equatable {
	var id: String {
		container.id
	}
	
	static func == (lhs: ContainerDetailView, rhs: ContainerDetailView) -> Bool {
		lhs.container.id == rhs.container.id
	}
}

fileprivate extension ContainerDetailView {
	struct GeneralSection: View {
		let container: PortainerKit.Container
		let details: PortainerKit.ContainerDetails

		var body: some View {
			LabeledSection(label: "ID", content: details.id, monospace: true, hideIfEmpty: false)
			LabeledSection(label: "Created", content: details.created.formatted(), hideIfEmpty: false)
			LabeledSection(label: "PID", content: "\(details.state.pid)", monospace: true, hideIfEmpty: false)
			LabeledSection(label: "Status", content: container.status ?? details.state.status.rawValue, monospace: true, hideIfEmpty: false)
			LabeledSection(label: "Error", content: details.state.error, monospace: true, hideIfEmpty: false)
			LabeledSection(label: "Started at", content: details.state.startedAt?.formatted(), hideIfEmpty: false)
			LabeledSection(label: "Finished at", content: details.state.finishedAt?.formatted(), hideIfEmpty: false)
		}
	}

	struct LogsSection: View {
		let logs: String
		let tailCount: Int

		var body: some View {
			CustomSection(label: "Logs (last \(tailCount) lines)") {
				Text(logs.isReallyEmpty ? "empty" : logs)
					.font(.system(.footnote, design: .monospaced))
					.foregroundStyle(logs.isReallyEmpty ? .secondary : .primary)
					.lineLimit(nil)
					.contentShape(Rectangle())
					.frame(maxWidth: .infinity, alignment: .topLeading)
					.textSelection(.enabled)
			}
			.frame(maxWidth: .infinity)
		}
	}

	struct DetailsSection: View {
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

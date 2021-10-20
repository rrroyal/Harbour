//
//  ContainerConfigDetailsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerConfigDetailsView: View {
	let config: PortainerKit.ContainerConfig?
	let hostConfig: PortainerKit.HostConfig?

	@ViewBuilder
	var emptyDisclaimer: some View {
		if config == nil /* && hostConfig == nil */ {
			Text("No config")
				.opacity(Globals.Views.secondaryOpacity)
		}
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 20) {
				if let config = config {
					ConfigSection(config: config)
				}
				
				/* if let hostConfig = hostConfig {
					HostConfigSection(config: hostConfig)
				} */
			}
			.padding()
		}
		.background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
		.overlay(emptyDisclaimer)
		.navigationTitle("Config")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: "Config", subtitle: nil)
		}
	}
}

extension ContainerConfigDetailsView {
	struct ConfigSection: View {
		let config: PortainerKit.ContainerConfig
		
		var body: some View {
			// DisclosureSection(label: "Config") {
			Group {
				Group {
					LabeledSection(label: "Hostname", content: config.hostname, monospace: true)
					LabeledSection(label: "Domain name", content: config.domainName, monospace: true)
					LabeledSection(label: "User", content: config.user, monospace: true)
					LabeledSection(label: "Attach stdin?", content: config.attachStdin.description, monospace: true)
					LabeledSection(label: "Attach stdout?", content: config.attachStdout.description, monospace: true)
				}
				
				Group {
					LabeledSection(label: "Attach stderr?", content: config.attachStdout.description, monospace: true)
					LabeledSection(label: "Exposed ports", content: config.exposedPorts?.map({ "\($0.key): \($0.value.description)" }).joined(separator: "\n"), monospace: true)
					LabeledSection(label: "Tty?", content: config.tty.description, monospace: true)
					LabeledSection(label: "Open stdin?", content: config.openStdin.description, monospace: true)
					LabeledSection(label: "Stdin once?", content: config.stdinOnce.description, monospace: true)
				}
				
				Group {
					LabeledSection(label: "Environment", content: config.env.joined(separator: "\n"), monospace: true)
					LabeledSection(label: "Cmd", content: config.cmd?.joined(separator: " "), monospace: true)
					// let healthCheck: HealthConfig?
					LabeledSection(label: "Args escaped?", content: config.argsEscaped?.description, monospace: true)
					LabeledSection(label: "Image", content: config.image.description, monospace: true)
				}
				
				Group {
					LabeledSection(label: "Volumes", content: config.volumes?.map({ "\($0.key): \($0.value.description)" }).joined(separator: "\n"), monospace: true)
					LabeledSection(label: "Working directory", content: config.workingDir, monospace: true)
					LabeledSection(label: "Entrypoint", content: config.entrypoint?.joined(separator: " "), monospace: true)
					LabeledSection(label: "Network disabled?", content: config.networkDisabled?.description, monospace: true)
					LabeledSection(label: "MAC Address", content: config.macAddress, monospace: true)
				}
				
				Group {
					LabeledSection(label: "On build", content: config.onBuild?.joined(separator: " "), monospace: true)
					// let labels: [String: String]
					LabeledSection(label: "Stop signal", content: config.stopSignal, monospace: true)
					LabeledSection(label: "Stop timeout", content: config.stopTimeout?.description, monospace: true)
					LabeledSection(label: "Shell", content: config.shell?.joined(separator: " "), monospace: true)
				}
			}
		}
	}
	
	struct HostConfigSection: View {
		let config: PortainerKit.HostConfig
		
		var body: some View {
			DisclosureSection(label: "Host config") {
				LabeledSection(label: "", content: nil)
			}
		}
	}
}

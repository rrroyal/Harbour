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
		if config == nil && hostConfig == nil {
			Text("No config")
				.opacity(Globals.Views.secondaryOpacity)
		}
	}
	
	var configSection: some View {
		Section("Config") {
			if let config = config {
				Text(String(describing: config))
			} else {
				Text("not loaded")
			}
		}
	}
	
	var hostConfigSection: some View {
		Section("Host config") {
			if let hostConfig = hostConfig {
				Text(String(describing: hostConfig))
			} else {
				Text("not loaded")
			}
		}
	}
	
	var body: some View {
		List {
			configSection
			hostConfigSection
		}
		.overlay(emptyDisclaimer)
		.navigationTitle("Config")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: "Config", subtitle: nil)
		}
	}
}

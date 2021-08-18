//
//  ContainerConfigDetailsView.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerConfigDetailsView: View {
	@ObservedObject var container: PortainerKit.Container
	let details: PortainerKit.ContainerDetails?
	
	@State private var isConfigSectionExpanded: Bool = true
	@State private var isHostConfigSectionExpanded: Bool = true

	var configSection: some View {
		Section(header: Text("Config")) {
			if let config = details?.config {
				Text(String(describing: config))
			} else {
				Text("not loaded")
			}
		}
	}
	
	var hostConfigSection: some View {
		Section(header: Text("Host config")) {
			if let hostConfig = details?.hostConfig ?? container.hostConfig {
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
		.navigationTitle("Config")
	}
}

//
//  ContainerNetworkDetailsView.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerNetworkDetailsView: View {
	let networkSettings: PortainerKit.Container.NetworkSettings?
	let details: PortainerKit.ContainerDetails.NetworkSettings?
	let ports: [PortainerKit.Port]?
	
	@ViewBuilder
	var networkSection: some View {
		Section {
			if let network = details {
				Labeled(label: "Address", content: network.address, monospace: true)
				Labeled(label: "Port mapping", content: network.portMapping, monospace: true)
				Labeled(label: "Bridge", content: network.bridge, monospace: true)
				Labeled(label: "Gateway", content: network.gateway, monospace: true)
				Labeled(label: "Mac address", content: network.macAddress, monospace: true)
				Labeled(label: "IP prefix len.", content: "\(network.ipPrefixLen)", monospace: true)
				// Labeled(label: "Ports", content: String(describing: network.ports), monospace: true)
			}
			
			/* if let network = container.networkSettings?.network {
				Labeled(label: "Links", content: network.links?.joined(separator: ", "), monospace: true)
				Labeled(label: "Aliases", content: network.aliases?.joined(separator: ", "), monospace: true)
				Labeled(label: "Network ID", content: network.networkID, monospace: true)
				Labeled(label: "Endpoint ID", content: network.endpointID, monospace: true)
				Labeled(label: "Gateway", content: network.gateway, monospace: true)
				Labeled(label: "IP Address", content: network.ipAddress?.description, monospace: true)
				Labeled(label: "IP prefix len.", content: network.ipPrefixLen?.description, monospace: true)
				Labeled(label: "IPv6 Gateway", content: network.ipv6Gateway, monospace: true)
				Labeled(label: "Global IPv6 Address", content: network.globalIPv6Address, monospace: true)
				Labeled(label: "Global IPv6 prefix len.", content: network.globalIPv6PrefixLen?.description, monospace: true)
				Labeled(label: "Mac address", content: network.macAddress, monospace: true)
			} */
		}
	}
	
	@ViewBuilder
	var portsSection: some View {
		if let ports = ports, !ports.isEmpty {
			ForEach(ports, id: \.self) { port in
				PortSection(port: port)
			}
		}
	}
	
	var body: some View {
		List {
			networkSection
			portsSection
		}
		.navigationTitle("Network")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: "Network", subtitle: nil)
		}
	}
}

private extension ContainerNetworkDetailsView {
	struct PortSection: View {
		let port: PortainerKit.Port
		let label: String?
		
		public init(port: PortainerKit.Port) {
			self.port = port
			
			if let privatePort = port.privatePort,
			   let type = port.type {
				label = "\(privatePort)/\(type.rawValue)"
			} else {
				label = nil
			}
		}
		
		var body: some View {
			Section(header: label != nil ? Text(label ?? "") : nil) {
				Labeled(label: "IP", content: port.ip != nil ? "\(port.ip ?? "")" : nil, monospace: true)
				Labeled(label: "Private port", content: port.privatePort != nil ? "\(port.privatePort ?? 0)" : nil, monospace: true)
				Labeled(label: "Public port", content: port.publicPort != nil ? "\(port.publicPort ?? 0)" : nil, monospace: true)
				Labeled(label: "Type", content: port.type != nil ? "\(port.type?.rawValue ?? "")" : nil, monospace: true)
			}
		}
	}
}

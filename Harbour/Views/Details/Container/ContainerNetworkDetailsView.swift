//
//  ContainerNetworkDetailsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerNetworkDetailsView: View {
	let container: PortainerKit.Container
	let details: PortainerKit.ContainerDetails?
	
	var body: some View {
		List {
			if let networks = container.networkSettings?.networks {
				Section(header: Text("Network")) {
					Text(String(describing: networks))
				}
			}
			
			if let ports = container.ports, !ports.isEmpty {
				ForEach(container.ports ?? [], id: \.self) { port in
					PortSection(port: port)
				}
			}
		}
		.navigationTitle("Network")
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
				self.label = "\(privatePort)/\(type.rawValue)"
			} else {
				self.label = nil
			}
		}
		
		var body: some View {
			Section(header: self.label != nil ? Text(self.label ?? "") : nil) {
				MonospaceLabeled(label: "IP", content: port.ip != nil ? "\(port.ip ?? "")" : nil)
				MonospaceLabeled(label: "Private port", content: port.privatePort != nil ? "\(port.privatePort ?? 0)" : nil)
				MonospaceLabeled(label: "Public port", content: port.publicPort != nil ? "\(port.publicPort ?? 0)" : nil)
				MonospaceLabeled(label: "Type", content: port.type != nil ? "\(port.type?.rawValue ?? "")" : nil)
			}
		}
	}
}

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
	
	var body: some View {
		List {
			if let networks = container.networkSettings?.networks {
				Section(header: Text("Networks")) {
					Text(String(describing: networks))
				}
			}
			
			if let ports = container.ports, !ports.isEmpty {
				Section(header: Text("Ports")) {
					ForEach(container.ports ?? [], id: \.self) { port in
						PortLabel(port: port)
					}
				}
			}
		}
		.navigationTitle(Text("Network"))
    }
}

fileprivate extension ContainerNetworkDetailsView {
	struct PortLabel: View {
		let port: PortainerKit.Port
		let label: String?
				
		init(port: PortainerKit.Port) {
			self.port = port
			
			var str = ""
			if let privatePort = port.privatePort { str += "\(privatePort)" }
			if let ip = port.ip { str += ":\(ip)" }
			if let publicPort = port.publicPort { str += ":\(publicPort)" }
			if let type = port.type { str += "/\(type.rawValue)" }
			
			self.label = str.isEmpty ? nil : str
		}
		
		var body: some View {
			Text(label ?? "empty")
				.foregroundColor(label != nil ? .primary : .secondary)
		}
	}
}

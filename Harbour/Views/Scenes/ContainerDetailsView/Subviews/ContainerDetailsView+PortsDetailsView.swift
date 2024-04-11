//
//  ContainerDetailsView+PortsDetailsView.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

extension ContainerDetailsView {
	struct PortsDetailsView: View {
		let ports: [PortainerKit.Port]?

		private var data: [KeyValueListView.Entry] {
			(ports ?? [])
				.map { entry in
					let privatePort = entry.privatePort ?? 0
					let publicPort = entry.publicPort ?? 0

					let key: String = if let type = entry.type {
						"\(privatePort)/\(type.rawValue)"
					} else {
						"\(privatePort)"
					}

					let value: String = if let ip = entry.ip {
						"\(ip):\(publicPort)"
					} else {
						"\(publicPort)"
					}

					return KeyValueListView.Entry(key: key, value: value)
				}
				.sorted(by: \.key)
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Ports")
		}
	}
}

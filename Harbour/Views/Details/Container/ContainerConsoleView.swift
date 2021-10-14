//
//  ContainerConsoleView.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import Combine
import PortainerKit
import SwiftUI

struct ContainerConsoleView: View {
	@EnvironmentObject var portainer: Portainer

	var body: some View {
		if let attachedContainer = portainer.attachedContainer {
			ScrollView {
				LazyVStack {
					Text(attachedContainer.string)
						.font(.system(.footnote, design: .monospaced))
						.lineLimit(nil)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				}
				.padding(.small)
			}
		} else {
			Text("how did you get here? ಠ_ಠ")
				.foregroundColor(.secondary)
		}
	}
}

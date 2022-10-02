//
//  ContainersView+ContainerContextMenu.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

extension ContainersView {
	struct ContainerContextMenu: View {
		@EnvironmentObject private var portainerStore: PortainerStore

		let container: Container

		// TODO: Context menu

		var body: some View {
			Button("Something") {
				print("something")
			}
		}
	}
}

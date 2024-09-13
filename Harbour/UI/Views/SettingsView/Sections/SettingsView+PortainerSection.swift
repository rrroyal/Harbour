//
//  SettingsView+PortainerSection.swift
//  Harbour
//
//  Created by royal on 03/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: SettingsView+PortainerSection

extension SettingsView {
	struct PortainerSection: View {
		@EnvironmentObject private var preferences: Preferences
		@Environment(SettingsView.ViewModel.self) var viewModel

		var body: some View {
			NormalizedSection {
//				ToggleOption(
//					"SettingsView.Portainer.ContainerRemoveForce.Title",
//					description: "SettingsView.Portainer.ContainerRemoveForce.Description",
//					iconSymbolName: SFSymbol.remove,
//					isOn: $preferences.containerRemoveForce
//				)
//				.id(SettingsView.ViewID.portainerContainerRemoveForce)

				ToggleOption(
					"SettingsView.Portainer.ContainerRemoveVolumes.Title",
					description: "SettingsView.Portainer.ContainerRemoveVolumes.Description",
					iconSymbolName: SFSymbol.volume,
					isOn: $preferences.containerRemoveVolumes
				)
				.id(SettingsView.ViewID.portainerContainerRemoveVolumes)
			} header: {
				Text("SettingsView.Portainer.Title")
			}
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.PortainerSection()
}
*/

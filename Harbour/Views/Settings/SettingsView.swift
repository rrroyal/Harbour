//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	@Environment(\.presentationMode) var presentationMode
	
	let listRowInsets = EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
	
	var body: some View {
		NavigationView {
			List {
				PortainerSection()
					.listRowInsets(listRowInsets)

				InterfaceSection()
					.listRowInsets(listRowInsets)

				OtherSection()
					.listRowInsets(listRowInsets)
			}
			.navigationTitle("Settings")
			#if targetEnvironment(macCatalyst)
			.toolbar {
				ToolbarItem(placement: .automatic) {
					Button("Close") {
						UIDevice.generateHaptic(.soft)
						presentationMode.wrappedValue.dismiss()
					}
				}
			}
			#endif
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
			.environmentObject(SceneState())
			.environmentObject(Portainer.shared)
			.environmentObject(Preferences.shared)
	}
}

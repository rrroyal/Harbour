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
	
	var body: some View {
		List {
			PortainerSection()
			InterfaceSection()
			OtherSection()
		}
		.listStyle(InsetGroupedListStyle())
		.navigationTitle("Settings")
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}

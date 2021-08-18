//
//  SettingsView.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	
	var body: some View {
		NavigationView {
			Form {
				PortainerSection()
				InterfaceSection()
				OtherSection()
			}
			.navigationTitle("Settings")
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}

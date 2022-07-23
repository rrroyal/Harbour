//
//  PortainerSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

extension SettingsView {
	struct PortainerSection: View {
		var body: some View {
			Section(Localizable.Settings.Portainer.title) {
				Text("portainer")
			}
		}
	}
}

struct PortainerSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.PortainerSection()
	}
}

//
//  GeneralSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

extension SettingsView {
	struct GeneralSection: View {
		var body: some View {
			Section(Localizable.Settings.General.title) {
				Text("general")
			}
		}
	}
}

struct GeneralSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.GeneralSection()
	}
}

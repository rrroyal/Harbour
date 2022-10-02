//
//  GeneralSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// MARK: SettingsView+GeneralSection

extension SettingsView {
	struct GeneralSection: View {
		var body: some View {
			Section(Localizable.Settings.General.title) {
				Text("general")
			}
		}
	}
}

// MARK: - Previews

struct GeneralSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.GeneralSection()
	}
}

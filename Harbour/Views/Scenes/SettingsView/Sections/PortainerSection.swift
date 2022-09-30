//
//  PortainerSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

extension SettingsView {
	struct PortainerSection: View {
		@State private var isSetupSheetPresented: Bool = false

		var body: some View {
			Section(Localizable.Settings.Portainer.title) {
				Button("Log in") {
					isSetupSheetPresented = true
				}
			}
			.sheet(isPresented: $isSetupSheetPresented) {
				SetupView()
			}
		}
	}
}

struct PortainerSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.PortainerSection()
	}
}

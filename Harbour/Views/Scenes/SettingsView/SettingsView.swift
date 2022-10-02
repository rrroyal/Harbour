//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

struct SettingsView: View {
	private typealias Localization = Localizable.Settings

//	let listRowInsets: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

	var body: some View {
		NavigationStack {
			List {
				Group {
					PortainerSection()
					GeneralSection()
					InterfaceSection()
					OtherSection()
				}
//				.listRowInsets(listRowInsets)
				.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			}
			.navigationTitle(Localization.title)
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}

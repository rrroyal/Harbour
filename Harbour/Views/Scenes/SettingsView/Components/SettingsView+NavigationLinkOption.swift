//
//  SettingsView+NavigationLinkOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

internal extension SettingsView {
	struct NavigationLinkOption<Destination: View>: View {
		let label: LocalizedStringKey
		let iconSymbolName: String
		let destination: Destination

		init(_ label: LocalizedStringKey, iconSymbolName: String, destination: @escaping () -> Destination) {
			self.label = label
			self.iconSymbolName = iconSymbolName
			self.destination = destination()
		}

		var body: some View {
			NavigationLink(destination: destination) {
				HStack {
					OptionIcon(symbolName: iconSymbolName)

					Text(label)
						.font(labelFontHeadline)
				}
			}
		}
	}
}

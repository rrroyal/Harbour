//
//  SettingsView+NavigationLinkOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

internal extension SettingsView {
	struct NavigationLinkOption<Destination: View>: View {
		let label: String
		let iconSymbolName: String
		let iconColor: Color
		let destination: Destination

		init(label: String, iconSymbolName: String, iconColor: Color, destination: @escaping () -> Destination) {
			self.label = label
			self.iconSymbolName = iconSymbolName
			self.iconColor = iconColor
			self.destination = destination()
		}

		var body: some View {
			NavigationLink(destination: destination) {
				HStack {
					OptionIcon(symbolName: iconSymbolName, color: iconColor)

					Text(label)
						.font(standaloneLabelFont)
				}
			}
		}
	}
}

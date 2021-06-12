//
//  NavigationLinkLabel.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct NavigationLinkLabel: View {
	let label: String
	let symbolName: String
	let backgroundColor: Color
	
	public init(label: String, symbolName: String, backgroundColor: Color = Color(uiColor: UIColor.secondarySystemGroupedBackground)) {
		self.label = label
		self.symbolName = symbolName
		self.backgroundColor = backgroundColor
	}
	
	var body: some View {
		HStack {
			Image(systemName: symbolName)
				.font(.callout.weight(.medium))
			
			Text(LocalizedStringKey(label))
				.font(.callout.weight(.medium))
			
			Spacer()
			
			Image(systemName: "chevron.forward")
				.font(.subheadline.weight(.bold))
				.foregroundStyle(.secondary)
				.opacity(Globals.Views.secondaryOpacity)
		}
		.padding(13)
		.background(
			RoundedRectangle(cornerRadius: Globals.Views.cornerRadius, style: .continuous)
				.fill(backgroundColor)
		)
	}
}

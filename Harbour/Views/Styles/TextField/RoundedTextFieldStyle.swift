//
//  RoundedTextFieldStyle.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
	let fontDesign: Font.Design
	
	init(fontDesign: Font.Design = .default) {
		self.fontDesign = fontDesign
	}
	
	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.font(.system(.callout, design: fontDesign).weight(.regular))
			.multilineTextAlignment(.center)
			.padding(.medium)
			.background(
				RoundedRectangle(cornerRadius: Globals.Views.cornerRadius, style: .continuous)
					.fill(Color(uiColor: .secondarySystemBackground))
			)
	}
}

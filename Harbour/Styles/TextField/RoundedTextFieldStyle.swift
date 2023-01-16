//
//  RoundedTextFieldStyle.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
	let fontDesign: Font.Design
	let backgroundColor: Color

	init(fontDesign: Font.Design = .default, backgroundColor: Color = Color(uiColor: .secondarySystemBackground)) {
		self.fontDesign = fontDesign
		self.backgroundColor = backgroundColor
	}

	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.font(.system(.callout, design: fontDesign).weight(.regular))
			.multilineTextAlignment(.center)
			.padding(.medium)
			.background(
				RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .circular)
					.fill(backgroundColor)
			)
	}
}

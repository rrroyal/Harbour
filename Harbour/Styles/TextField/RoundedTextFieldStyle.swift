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

	init(fontDesign: Font.Design = .default, backgroundColor: Color = .secondaryBackground) {
		self.fontDesign = fontDesign
		self.backgroundColor = backgroundColor
	}

	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.font(.system(.callout, design: fontDesign).weight(.regular))
			.multilineTextAlignment(.center)
			.padding(10)
			.background(
				RoundedRectangle(cornerRadius: Constants.cornerRadius)
					.fill(backgroundColor)
			)
	}
}

extension TextFieldStyle where Self == RoundedTextFieldStyle {
	static var rounded: Self { .init() }
	static func rounded(fontDesign: Font.Design = .default,
						backgroundColor: Color = .secondaryBackground) -> Self {
		RoundedTextFieldStyle(fontDesign: fontDesign, backgroundColor: backgroundColor)
	}
}

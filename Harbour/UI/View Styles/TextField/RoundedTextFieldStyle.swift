//
//  RoundedTextFieldStyle.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
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
			.textFieldStyle(.plain)
			.font(.callout)
			.padding(.horizontal)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 10, style: .circular)
					.fill(backgroundColor)
			)
	}
}

extension TextFieldStyle where Self == RoundedTextFieldStyle {
	static var rounded: Self { .init() }
	static func rounded(
		backgroundColor: Color = .secondaryBackground
	) -> Self {
		RoundedTextFieldStyle(backgroundColor: backgroundColor)
	}
}

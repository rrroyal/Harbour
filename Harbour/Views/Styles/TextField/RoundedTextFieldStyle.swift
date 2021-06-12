//
//  RoundedTextFieldStyle.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.font(.callout.weight(.regular))
			.multilineTextAlignment(.center)
			.padding(.medium)
			.background(
				RoundedRectangle(cornerRadius: Globals.Views.cornerRadius, style: .continuous)
					.fill(Color(uiColor: .secondarySystemBackground))
			)
	}
}

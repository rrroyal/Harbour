//
//  buttonStyle.swift
//  Harbour
//
//  Created by royal on 26/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@inlinable @ViewBuilder
	func buttonStyle(_ style: (some PrimitiveButtonStyle)?) -> some View {
		if let style {
			self
				.buttonStyle(style)
		} else {
			self
		}
	}
}

enum _ButtonStyle {
	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	static var glass: (some PrimitiveButtonStyle)? {
		if #available(anyAppleOS 26.0, *) {
			GlassButtonStyle()
		} else {
			nil
		}
	}

	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	static var glassProminent: (some PrimitiveButtonStyle)? {
		if #available(anyAppleOS 26.0, *) {
			GlassProminentButtonStyle()
		} else {
			nil
		}
	}
}

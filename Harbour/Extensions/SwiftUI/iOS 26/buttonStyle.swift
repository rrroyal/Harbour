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
	static var glass: (some PrimitiveButtonStyle)? {
		if #available(iOS 26.0, macOS 26.0, *) {
			GlassButtonStyle()
		} else {
			nil
		}
	}

	static var glassProminent: (some PrimitiveButtonStyle)? {
		if #available(iOS 26.0, macOS 26.0, *) {
			GlassProminentButtonStyle()
		} else {
			nil
		}
	}
}

//
//  View+opacity.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// TODO: Check if it's needed

enum ViewOpacity: Double {
	case primary = 1.0
	case secondary = 0.3
	case candy = 0.12
}

extension View {
	@ViewBuilder
	func opacity(_ opacity: ViewOpacity) -> some View {
		self.opacity(opacity.rawValue)
	}
}

//
//  buttonSizing.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _buttonSizingFitted() -> some View {
		if #available(anyAppleOS 26.0, *) {
			self
				.buttonSizing(.fitted)
		} else {
			self
		}
	}

	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _buttonSizingFlexible() -> some View {
		if #available(anyAppleOS 26.0, *) {
			self
				.buttonSizing(.flexible)
		} else {
			self
		}
	}
}

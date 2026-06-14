//
//  glassEffect.swift
//  Harbour
//
//  Created by royal on 17/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _glassEffect(tint color: Color? = nil, in shape: some Shape = .rect) -> some View {
		if #available(anyAppleOS 26.0, *) {
			self
				.glassEffect(.regular.tint(color), in: shape)
		} else {
			self
				.background(.ultraThinMaterial, in: shape)
		}
	}

	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _glassEffectInteractive(tint color: Color? = nil, enabled: Bool = true) -> some View {
		if #available(anyAppleOS 26.0, *) {
			self
				.glassEffect(.regular.interactive(enabled).tint(color))
		} else {
			self
		}
	}
}

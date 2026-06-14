//
//  inGlassEffectContainer.swift
//  Harbour
//
//  Created by royal on 26/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _inGlassEffectContainer(spacing: CGFloat? = nil) -> some View {
		if #available(anyAppleOS 26.0, *) {
			GlassEffectContainer(spacing: spacing) {
				self
			}
		} else {
			self
		}
	}
}

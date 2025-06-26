//
//  inGlassEffectContainer.swift
//  Harbour
//
//  Created by royal on 26/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder @inlinable
	func _inGlassEffectContainer(spacing: CGFloat? = nil) -> some View {
		if #available(iOS 26.0, macOS 26.0, *) {
			GlassEffectContainer(spacing: spacing) {
				self
			}
		} else {
			self
		}
	}
}

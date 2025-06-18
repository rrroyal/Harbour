//
//  GlassIfAvailable.swift
//  Harbour
//
//  Created by royal on 17/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder @inlinable
	func _glassEffect() -> some View {
		if #available(iOS 26.0, *) {
			self
				.glassEffect()
		} else {
			self
		}
	}

	@ViewBuilder @inlinable
	func _glassEffect(tint: Color) -> some View {
		if #available(iOS 26.0, *) {
			self
				.glassEffect(.regular.tint(tint))
		} else {
			self
		}
	}
}

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
	func _glassEffect(tint color: Color? = nil) -> some View {
		if #available(iOS 26.0, macOS 26.0, *) {
			self
				.glassEffect(.regular.tint(color))
		} else {
			self
		}
	}

	@ViewBuilder @inlinable
	func _glassEffectInteractive(tint color: Color? = nil, enabled: Bool = true) -> some View {
		if #available(iOS 26.0, macOS 26.0, *) {
			self
				.glassEffect(.regular.interactive(enabled).tint(color))
		} else {
			self
		}
	}
}

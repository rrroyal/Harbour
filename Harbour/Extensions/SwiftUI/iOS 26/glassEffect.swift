//
//  GlassIfAvailable.swift
//  Harbour
//
//  Created by royal on 17/06/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder
	func _glassEffect() -> some View {
		if #available(iOS 26.0, *) {
			self
				.glassEffect()
		} else {
			self
		}
	}
}

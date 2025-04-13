//
//  Binding+withHaptics.swift
//  Harbour
//
//  Created by royal on 25/12/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension Binding where Value: Sendable {
	func withHaptics(_ haptic: Haptics.HapticStyle) -> Self {
		.init {
			self.wrappedValue
		} set: { newValue in
			Haptics.generateIfEnabled(haptic)
			self.wrappedValue = newValue
		}
	}
}

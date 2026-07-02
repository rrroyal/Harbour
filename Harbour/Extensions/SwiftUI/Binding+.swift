//
//  Binding+.swift
//  Harbour
//
//  Created by royal on 25/12/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension Binding where Value: Sendable {
	func withHaptics(_ haptic: Haptics.HapticStyle = .selectionChanged) -> Self {
		.init {
			self.wrappedValue
		} set: { newValue in
			Haptics.generateIfEnabled(haptic)
			self.wrappedValue = newValue
		}
	}
}

extension Binding where Value: Sendable {
	func unwrapping<Wrapped>(
		default defaultValue: Wrapped
	) -> Binding<Wrapped> where Value == Wrapped? {
		.init {
			self.wrappedValue ?? defaultValue
		} set: {
			self.wrappedValue = $0
		}
	}
}

extension Binding where Value == String {
	/// Returns a binding that replaces every occurrence of `character` with `replacement` as the user types.
	func replacing(_ character: Character, with replacement: Character) -> Self {
		.init {
			self.wrappedValue
		} set: {
			self.wrappedValue = $0.replacingOccurrences(of: String(character), with: String(replacement))
		}
	}

	/// Returns a binding that trims characters in the specified set from the beginning and end of the string as the user types.
	func trimmingCharacters(in set: CharacterSet) -> Self {
		.init {
			self.wrappedValue
		} set: {
			self.wrappedValue = $0.trimmingCharacters(in: set)
		}
	}
}

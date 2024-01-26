//
//  View+if.swift
//  Harbour
//
//  Created by royal on 15/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension View {
	/// Applies the given transform if the given condition evaluates to `true`.
	/// - Parameters:
	///   - condition: The condition to evaluate.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
		if condition() {
			transform(self)
		} else {
			self
		}
	}

	/// Applies the given transform if the given optional isn't `nil`.
	/// - Parameters:
	///   - value: The value to check.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the value isn't `nil`.
	@ViewBuilder func `if`<Content: View, Value>(`let` value: @autoclosure () -> Value?, transform: (Self, Value) -> Content) -> some View {
		if let value = value() {
			transform(self, value)
		} else {
			self
		}
	}
}

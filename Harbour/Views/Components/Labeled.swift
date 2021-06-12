//
//  Labeled.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//	Borrowed from https://github.com/SwiftUIX/SwiftUIX
//

import SwiftUI

public struct Labeled<Label: View, Control: View>: View {
	@usableFromInline
	let label: Label

	@usableFromInline
	let control: Control

	public var body: some View {
		HStack {
			label

			Spacer()

			control
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.trailing)
		}
	}
}

public extension Labeled {
	@inlinable
	init(
		@ViewBuilder control: () -> Control,
		@ViewBuilder label: () -> Label
	) {
		self.label = label()
		self.control = control()
	}
}

public extension Labeled where Label == Text {
	@inlinable
	init(
		_ title: Text,
		@ViewBuilder control: () -> Control
	) {
		self.init(control: control, label: { title })
	}

	@inlinable
	init<S: StringProtocol>(
		_ title: S,
		@ViewBuilder control: () -> Control
	) {
		self.init(Text(title), control: control)
	}
}

//
//  ContainerDetailsView+Components.swift
//  Harbour
//
//  Created by royal on 03/12/2022.
//

import SwiftUI

extension ContainerDetailsView {
	struct BooleanLabel: View {
		let value: Bool

		var body: some View {
			Text(value.description)
				.foregroundColor(value ? .green : .red)
				.textSelection(.enabled)
		}
	}

	struct MonospaceLabel: View {
		let value: String

		var body: some View {
			Text(value)
				.fontDesign(.monospaced)
				.textSelection(.enabled)
		}
	}
}

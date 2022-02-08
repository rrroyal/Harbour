//
//  CustomSection.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI

/* yeah, i'm sorry */

struct CustomSection<Content: View>: View {
	let label: String
	@ViewBuilder let content: () -> Content
		
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(label)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.textCase(.uppercase)
				.multilineTextAlignment(.leading)
				.padding(.horizontal)

			content()
				.padding(.medium)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(
					RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
						.fill(Color(uiColor: .secondarySystemGroupedBackground))
				)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

struct CustomSection_Previews: PreviewProvider {
    static var previews: some View {
		CustomSection(label: "Label") {
			Text("ahh")
		}
		.padding()
		.previewLayout(.sizeThatFits)
    }
}

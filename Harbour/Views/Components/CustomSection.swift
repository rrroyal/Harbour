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
			Text(LocalizedStringKey(label))
				.font(.footnote)
				.foregroundColor(.secondary)
				.textCase(.uppercase)
				.padding(.horizontal)
			
			content()
				.padding(.medium)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(
					RoundedRectangle(cornerRadius: Globals.Views.cornerRadius, style: .continuous)
						.fill(Color(UIColor.secondarySystemGroupedBackground))
				)
		}
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

//
//  SelectContainerPlaceholder.swift
//  HarbourWidgets
//
//  Created by royal on 04/10/2022.
//

import SwiftUI

// MARK: - SelectContainerPlaceholder

struct SelectContainerPlaceholder: View {
	var body: some View {
		Text(Localizable.Widget.selectContainerPlaceholder)
			.font(.body.weight(.medium))
			.foregroundStyle(.secondary)
			.multilineTextAlignment(.center)
			.padding()
	}
}

// MARK: - Previews

#Preview {
	SelectContainerPlaceholder()
}

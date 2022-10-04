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
		Text(Localizable.Widgets.selectContainerPlaceholder)
			.font(.body.weight(.medium))
			.foregroundStyle(.secondary)
			.multilineTextAlignment(.center)
			.padding()
	}
}

// MARK: - Previews

struct SelectContainerPlaceholder_Previews: PreviewProvider {
	static var previews: some View {
		SelectContainerPlaceholder()
	}
}

//
//  SelectContainerView.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//

import PortainerKit
import SwiftUI
import WidgetKit

// MARK: - SelectContainerView

struct SelectContainerView: View {
	var entry: ContainerStatusProvider.Entry

	var body: some View {
		VStack(spacing: 4) {
			Text("SelectContainerView.Title")
				.font(.body)
				.fontWeight(.medium)
				.foregroundStyle(.secondary)

			/*
			#if DEBUG
			VStack {
				Text(String(describing: entry.configuration.endpoint.id))
				Text(String(describing: entry.configuration.containers))
			}
			.font(.caption2)
			.fontWeight(.medium)
			.fontDesign(.monospaced)
			#endif
			 */
		}
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
		.containerBackground(for: .widget) {
			Color.widgetBackground
		}
	}
}

// MARK: - Previews

#Preview {
	SelectContainerView(entry: .placeholder)
}

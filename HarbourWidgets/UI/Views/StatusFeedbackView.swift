//
//  StatusFeedbackView.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

// MARK: - StatusFeedbackView

struct StatusFeedbackView: View {
	@Environment(\.widgetFamily) private var widgetFamily
	var mode: Mode

	private var includePadding: Bool {
		switch widgetFamily {
		case .accessoryCircular, .accessoryInline:
			false
		case .accessoryRectangular:
			false
		case .systemExtraLarge, .systemLarge, .systemMedium, .systemSmall:
			true
		@unknown default:
			true
		}
	}

	var body: some View {
		Text(mode.title)
			.font(.body)
			.fontWeight(.medium)
			.foregroundStyle(.secondary)
			.multilineTextAlignment(.center)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding(.all, includePadding ? nil : 0)
			.containerBackground(for: .widget) {
				Color.widgetBackground
			}
	}
}

// MARK: - StatusFeedbackView+Mode

extension StatusFeedbackView {
	enum Mode {
		case selectContainer(long: Bool = true)
		case containerNotFound

		var title: LocalizedStringKey {
			switch self {
			case .selectContainer(let long):
				long ? "StatusFeedbackView.Headline.SelectContainer.Long" : "StatusFeedbackView.Headline.SelectContainer.Short"
			case .containerNotFound:
				"StatusFeedbackView.Headline.ContainerNotFound"
			}
		}
	}
}

// MARK: - Previews

#Preview("Select Container") {
	StatusFeedbackView(mode: .selectContainer())
}

#Preview("Container Not Found") {
	StatusFeedbackView(mode: .containerNotFound)
}

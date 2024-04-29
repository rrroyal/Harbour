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
	var entry: ContainerStatusProvider.Entry
	var mode: Mode

	var body: some View {
		VStack(spacing: 4) {
			Text(mode.title)
				.font(.body)
				.fontWeight(.medium)
				.foregroundStyle(.secondary)
		}
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
		.containerBackground(for: .widget) {
			Color.widgetBackground
		}
	}
}

// MARK: - StatusFeedbackView+Mode

extension StatusFeedbackView {
	enum Mode {
		case selectContainer
		case containerNotFound

		var title: LocalizedStringKey {
			switch self {
			case .selectContainer:
				"StatusFeedbackView.Headline.SelectContainer"
			case .containerNotFound:
				"StatusFeedbackView.Headline.ContainerNotFound"
			}
		}
	}
}

// MARK: - Previews

#Preview("Select Container") {
	StatusFeedbackView(entry: .placeholder, mode: .selectContainer)
}

#Preview("Container Not Found") {
	StatusFeedbackView(entry: .placeholder, mode: .containerNotFound)
}

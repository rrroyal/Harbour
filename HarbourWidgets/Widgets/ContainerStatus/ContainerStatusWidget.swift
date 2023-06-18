//
//  ContainerStatusWidget.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//

import WidgetKit
import SwiftUI

// MARK: - ContainerStatusWidget

struct ContainerStatusWidget: Widget {
	let kind: String = "ContainerStatusWidget"

	var body: some WidgetConfiguration {
		AppIntentConfiguration(
			kind: kind,
			intent: ContainerStatusProvider.IntentConfiguration.self,
			provider: ContainerStatusProvider()) { entry in
			ContainerStatusWidgetView(entry: entry)
		}
		.configurationDisplayName("ContainerStatusWidget.DisplayName")
		.description("ContainerStatusWidget.Description")
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
		.contentMarginsDisabled()
		.containerBackgroundRemovable()
	}
}

// MARK: - Previews

#Preview("ContainerStatusWidget - Small", as: .systemSmall) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusProvider.Entry.placeholder
}

#Preview("ContainerStatusWidget - Medium", as: .systemMedium) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusProvider.Entry.placeholder
}

#Preview("ContainerStatusWidget - Large", as: .systemLarge) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusProvider.Entry.placeholder
}

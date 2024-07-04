//
//  ContainerStatusWidget.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - ContainerStatusWidget

struct ContainerStatusWidget: Widget {
	private let kind: String = HarbourWidgetKind.containerStatus
	private var families: [WidgetFamily] {
		#if os(iOS)
		[.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryInline, .accessoryRectangular]
		#elseif os(macOS)
		[.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
		#endif
	}

	var body: some WidgetConfiguration {
		AppIntentConfiguration(
			kind: kind,
			intent: ContainerStatusWidget.Intent.self,
			provider: ContainerStatusWidget.Provider()
		) { entry in
			ContainerStatusWidget.ContentView(entry: entry)
		}
		.configurationDisplayName("ContainerStatusWidget.DisplayName")
		.description("ContainerStatusWidget.Description")
		.supportedFamilies(families)
		.contentMarginsDisabled()
		.containerBackgroundRemovable()
	}
}

// MARK: - Previews

#if os(iOS)
#Preview("Accessory Rectangular", as: .accessoryRectangular) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusWidget.Entry.placeholder
}
#endif

#Preview("Small", as: .systemSmall) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusWidget.Entry.placeholder
}

#Preview("Medium", as: .systemMedium) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusWidget.Entry.placeholder
}

#Preview("Large", as: .systemLarge) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusWidget.Entry.placeholder
}

#Preview("Extra Large", as: .systemExtraLarge) {
	ContainerStatusWidget()
} timeline: {
	ContainerStatusWidget.Entry.placeholder
}

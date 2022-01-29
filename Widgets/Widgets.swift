//
//  Widgets.swift
//  Widgets
//
//  Created by royal on 17/01/2022.
//

import WidgetKit
import SwiftUI
import Intents
import os.log

@main
struct Widgets: Widget {
    var body: some WidgetConfiguration {
		IntentConfiguration(kind: Constants.Widgets.statusWidgetKind, intent: GetContainerStatusIntent.self, provider: GetContainerStatusWidget.Provider()) { entry in
			GetContainerStatusWidget.WidgetView(entry: entry)
				.widgetURL(entry.configuration.container?.identifier != nil ? HarbourURLScheme.openContainer(containerID: entry.configuration.container?.identifier ?? "").url : nil)
        }
		.configurationDisplayName(Localization.WIDGET_STATUS_NAME.localized)
		.description(Localization.WIDGET_STATUS_DESCRIPTION.localized)
		.supportedFamilies([.systemSmall])
    }
}

extension Widgets {
	internal static let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Widgets")
}

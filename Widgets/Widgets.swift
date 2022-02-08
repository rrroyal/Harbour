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
		IntentConfiguration(kind: Constants.Widgets.statusWidgetKind, intent: ContainerStatusIntent.self, provider: ContainerStatusWidget.Provider()) { entry in
			ContainerStatusWidget.WidgetView(entry: entry)
        }
		.configurationDisplayName(Localization.Widgets.StatusWidget.name)
		.description(Localization.Widgets.StatusWidget.description)
		.supportedFamilies([.systemSmall])
    }
}

extension Widgets {
	internal static let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Widgets")
}

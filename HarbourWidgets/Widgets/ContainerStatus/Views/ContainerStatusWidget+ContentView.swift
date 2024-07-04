//
//  ContainerStatusWidget+ContentView.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

extension ContainerStatusWidget {
	struct ContentView: View {
		typealias Entry = ContainerStatusWidget.Provider.Entry

		@Environment(\.widgetFamily) private var widgetFamily
		var entry: Entry

		var body: some View {
			switch entry.result {
			case .containers, .unreachable, .unconfigured:
				switch widgetFamily {
				case .accessoryInline:
					AccessoryInlineView(entry: entry)
				case .accessoryRectangular:
					AccessoryRectangularView(entry: entry)
				case .systemSmall:
					SingleContainerView(entry: entry)
				case .systemMedium:
					ContainerGridView(entry: entry, rows: 1, columns: 2)
				case .systemLarge:
					ContainerGridView(entry: entry, rows: 2, columns: 2)
				case .systemExtraLarge:
					ContainerGridView(entry: entry, rows: 2, columns: 4)
				default:
					EmptyView()
						.containerBackground(Color.widgetBackground, for: .widget)
				}
			case .error(let error):
				ErrorView(error: error)
			}
		}
	}
}

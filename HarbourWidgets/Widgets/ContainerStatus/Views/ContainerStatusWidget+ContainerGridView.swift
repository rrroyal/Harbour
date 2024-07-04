//
//  ContainerStatusWidget+ContainerGridView.swift
//  HarbourWidgets
//
//  Created by royal on 23/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

extension ContainerStatusWidget {
	struct ContainerGridView: View {
		var entry: ContainerStatusWidget.Provider.Entry
		var rows: Int
		var columns: Int

		private let padding: Double = 8

		private var containers: [Container?]? {
			if case .containers(let containers) = entry.result {
				return containers
			}
			return nil
		}

		private var useCompactSpacing: Bool {
			#if canImport(UIKit)
			UIDevice.current.userInterfaceIdiom == .phone
			#else
			false
			#endif
		}

		var body: some View {
			VStack(spacing: -padding) {
				ForEach(0..<rows, id: \.self) { yIndex in
					HStack(spacing: -padding) {
						ForEach(0..<columns, id: \.self) { xIndex in
							let index = (yIndex * columns) + xIndex
							let intentContainer = entry.configuration.containers[safe: index]
							let container = containers?[safe: index] as? Container

							Group {
								if let intentContainer {
									ContainerStatusWidget.ContainerView(
										entry: entry,
										intentContainer: intentContainer,
										container: container
									)
								} else {
									StatusFeedbackView(mode: .selectContainer())
								}
							}
							.modifier(InsetViewModifier())
							.padding(padding)
						}
					}
				}
			}
			.containerBackground(for: .widget) {
				Color.widgetBackgroundSecondary
			}
		}
	}
}

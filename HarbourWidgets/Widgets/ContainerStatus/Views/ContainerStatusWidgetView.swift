//
//  ContainerStatusWidgetView.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

// MARK: - ContainerStatusWidgetView

struct ContainerStatusWidgetView: View {
	typealias Entry = ContainerStatusProvider.Entry

	@Environment(\.widgetFamily) private var widgetFamily
	var entry: Entry

	var body: some View {
		switch entry.result {
		case .containers, .unreachable, .unconfigured:
			switch widgetFamily {
			case .systemSmall:
				SmallWidgetView(entry: entry)
			case .systemMedium:
				MediumWidgetView(entry: entry)
			case .systemLarge:
				LargeWidgetView(entry: entry)
			default:
				// Fallback
				SmallWidgetView(entry: entry)
			}
		case .error(let error):
			ErrorView(error: error)
		}
	}
}

// MARK: - ContainerStatusWidgetView+SingleContainerSlotView

extension ContainerStatusWidgetView {
	struct SingleContainerSlotView: View {
		var entry: ContainerStatusWidgetView.Entry
		var intentContainer: IntentContainer?
		var container: Container?

		var body: some View {
			if let intentContainer {
				ContainerStatusWidgetView.ContainerView(
					entry: entry,
					intentContainer: intentContainer,
					container: container
				)
			} else {
				StatusFeedbackView(entry: entry, mode: .selectContainer)
			}
		}
	}
}

// MARK: - ContainerStatusWidgetView+SmallWidgetView

extension ContainerStatusWidgetView {
	struct SmallWidgetView: View {
		var entry: ContainerStatusProvider.Entry

		private var intentContainer: IntentContainer? {
			entry.configuration.containers?.first
		}

		private var containers: [Container?]? {
			if case .containers(let containers) = entry.result {
				return containers
			}
			return nil
		}

		var body: some View {
			SingleContainerSlotView(
				entry: entry,
				intentContainer: intentContainer,
				container: containers?.first as? Container
			)
			.containerBackground(for: .widget) {
				Color.widgetBackground
			}
		}
	}
}

// MARK: - ContainerStatusWidgetView+MediumWidgetView

extension ContainerStatusWidgetView {
	struct MediumWidgetView: View {
		var entry: ContainerStatusProvider.Entry

		private let padding: Double = 8

		private var containers: [Container?]? {
			if case .containers(let containers) = entry.result {
				return containers
			}
			return nil
		}

		var body: some View {
			HStack(spacing: -padding) {
				ForEach(0...1, id: \.self) { index in
					let intentContainer = entry.configuration.containers?[safe: index]
					let container = containers?[safe: index] as? Container

					SingleContainerSlotView(
						entry: entry,
						intentContainer: intentContainer,
						container: container
					)
					.modifier(InsetViewModifier())
					.padding(padding)
				}
			}
			.containerBackground(for: .widget) {
				Color.widgetBackgroundSecondary
			}
		}
	}
}

// MARK: - ContainerStatusWidgetView+LargeWidgetView

extension ContainerStatusWidgetView {
	struct LargeWidgetView: View {
		var entry: ContainerStatusProvider.Entry

		private let padding: Double = 10

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
				ForEach(0...1, id: \.self) { yIndex in
					HStack(spacing: -padding) {
						ForEach(0...1, id: \.self) { xIndex in
							let index = (yIndex * 2) + xIndex
							let intentContainer = entry.configuration.containers?[safe: index]
							let container = containers?[safe: index] as? Container

							SingleContainerSlotView(
								entry: entry,
								intentContainer: intentContainer,
								container: container
							)
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

// MARK: - Previews

#Preview("ContainerStatusWidgetView - Small") {
	ContainerStatusWidgetView(entry: .placeholder)
		.previewContext(WidgetPreviewContext(family: .systemSmall))
}

#Preview("ContainerStatusWidgetView - Medium") {
	ContainerStatusWidgetView(entry: .placeholder)
		.previewContext(WidgetPreviewContext(family: .systemMedium))
}

#Preview("ContainerStatusWidgetView - Large") {
	ContainerStatusWidgetView(entry: .placeholder)
		.previewContext(WidgetPreviewContext(family: .systemLarge))
}

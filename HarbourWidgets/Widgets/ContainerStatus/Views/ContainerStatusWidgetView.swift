//
//  ContainerStatusWidgetView.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//

import PortainerKit
import SwiftUI
import WidgetKit

// MARK: - ContainerStatusWidgetView

struct ContainerStatusWidgetView: View {
	@Environment(\.widgetFamily) private var widgetFamily
	var entry: ContainerStatusProvider.Entry

	var body: some View {
		if let error = entry.error {
			ErrorView(error: error)
		} else {
			switch widgetFamily {
			case .systemSmall:
				let firstContainer = entry.configuration.containers.first
				let widgetURL = HarbourURLScheme.containerDetails(id: firstContainer?._id ?? "", displayName: firstContainer?.name, endpointID: entry.configuration.endpoint?.id).url
				SmallWidgetView(entry: entry)
					.widgetURL(widgetURL)
			case .systemMedium:
				MediumWidgetView(entry: entry)
			case .systemLarge:
				LargeWidgetView(entry: entry)
			default:
				// Fallback
				SmallWidgetView(entry: entry)
			}
		}
	}
}

// MARK: - ContainerStatusWidgetView+SmallWidgetView

extension ContainerStatusWidgetView {
	struct SmallWidgetView: View {
		var entry: ContainerStatusProvider.Entry

		private var intentContainer: IntentContainer? {
			entry.configuration.containers.first
		}

		private var container: Container? {
			entry.containers?.first { $0.id == intentContainer?._id }
		}

		var body: some View {
			Group {
				if let intentEndpoint = entry.configuration.endpoint, let intentContainer {
					ContainerStatusWidgetView.ContainerView(
						entry: entry,
						intentContainer: intentContainer,
						intentEndpoint: intentEndpoint,
						container: container
					)
				} else {
					SelectContainerView(entry: entry)
				}
			}
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

		var body: some View {
			HStack {
				ForEach(0..<2, id: \.self) { index in
					Group {
						if let intentEndpoint = entry.configuration.endpoint,
						   let intentContainer = entry.configuration.containers[safe: index] {
							let container = entry.containers?.first { $0.id == intentContainer ._id }
							ContainerStatusWidgetView.ContainerView(
								entry: entry,
								intentContainer: intentContainer,
								intentEndpoint: intentEndpoint,
								container: container
							)
						} else {
							SelectContainerView(entry: entry)
						}
					}
					.modifier(InsetViewModifier())
					.containerRelativeFrame(.horizontal, count: 2, spacing: 0)
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

		var body: some View {
			VStack {
				ForEach(0...1, id: \.self) { yIndex in
					HStack(spacing: 0) {
						ForEach(0..<2, id: \.self) { xIndex in
							Group {
								let index = (yIndex * 2) + xIndex
								if let intentEndpoint = entry.configuration.endpoint,
								   let intentContainer = entry.configuration.containers[safe: index] {
									let container = entry.containers?.first { $0.id == intentContainer._id }
									ContainerStatusWidgetView.ContainerView(
										entry: entry,
										intentContainer: intentContainer,
										intentEndpoint: intentEndpoint,
										container: container
									)
								} else {
									SelectContainerView(entry: entry)
								}
							}
							.modifier(InsetViewModifier())
							.containerRelativeFrame(.horizontal, count: 2, spacing: 0)
							.containerRelativeFrame(.vertical, count: 2, spacing: 0)
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

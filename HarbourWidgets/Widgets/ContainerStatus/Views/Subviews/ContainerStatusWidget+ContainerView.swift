//
//  ContainerStatusWidget+ContainerView.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Navigation
import PortainerKit
import SwiftUI
import WidgetKit

// MARK: - ContainerStatusWidget+ContainerView

extension ContainerStatusWidget {
	struct ContainerView: View {
		@Environment(\.redactionReasons) private var redactionReasons
		var entry: ContainerStatusWidget.Provider.Entry
		var intentContainer: IntentContainer
		var container: Container?

		@ScaledMetric(relativeTo: .body)
		private var fontSize = 8

		private let circleSize: Double = 8
		private let minimumScaleFactor: Double = 0.8

		private var url: URL? {
			guard !entry.isPlaceholder else { return nil }

			let deeplink = Deeplink.ContainerDetailsDestination(
				containerID: container?.id ?? intentContainer._id,
				containerName: container?.displayName ?? intentContainer.name,
				endpointID: entry.configuration.endpoint?.id,
				persistentID: intentContainer.persistentID ?? container?._persistentID
			)
			return deeplink.url ?? Deeplink.appURL
		}

		private var statusPlaceholder: String {
			switch entry.result {
			case .containers:
				// Shouldn't ever be displayed
				String(localized: "Generic.Unknown")
			case .error(let error):
				error.localizedDescription
			case .unreachable:
				String(localized: "Generic.Unreachable")
			case .unconfigured:
				// Shouldn't ever be displayed
				String(localized: "Generic.Unknown")
			}
		}

		@ViewBuilder @MainActor
		private var stateHeadline: some View {
			Text(verbatim: (container?.state ?? Container.State?.none).title)
				#if os(macOS)
				.font(.body)
				.fontWeight(.medium)
				#else
				.font(.subheadline)
				.fontWeight(.medium)
				#endif
				.foregroundStyle(.tint)
				.minimumScaleFactor(minimumScaleFactor)
		}

		@ViewBuilder @MainActor
		private var stateIcon: some View {
			Circle()
				.fill(redactionReasons.isEmpty ? AnyShapeStyle(.tint) : AnyShapeStyle(.tint.secondary))
				.frame(width: circleSize, height: circleSize)
		}

		@ViewBuilder @MainActor
		private var dateLabel: some View {
			Group {
				if redactionReasons.isEmpty {
					Text(entry.date, style: .relative)
				} else {
					Text(entry.date.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)))
				}
			}
			#if os(macOS)
			.font(.subheadline)
			.fontWeight(.regular)
			#else
			.font(.caption2)
			.fontWeight(.medium)
			#endif
			.foregroundStyle(.tertiary)
		}

		@ViewBuilder @MainActor
		private var nameLabel: some View {
			let displayName = container?.displayName ?? intentContainer.name
			Text(verbatim: displayName ?? String(localized: "Generic.Unknown"))
				#if os(macOS)
				.font(.title2)
				.fontWeight(.medium)
				#else
				.font(.body)
				.fontWeight(.semibold)
				#endif
				.foregroundStyle(displayName != nil ? .primary : .secondary)
				.lineLimit(2)
		}

		@ViewBuilder @MainActor
		private var statusLabel: some View {
			Text(verbatim: container?.status ?? statusPlaceholder)
				#if os(macOS)
				.font(.body)
				.fontWeight(.regular)
				#else
				.font(.subheadline)
				.fontWeight(.medium)
				#endif
				.foregroundStyle(container?.status != nil ? .secondary : .tertiary)
				.lineLimit(2)
		}

		var body: some View {
			VStack(spacing: 0) {
				HStack {
					stateHeadline

					Spacer()

					stateIcon
				}

				dateLabel
					.frame(maxWidth: .infinity, alignment: .leading)

				Spacer()

				Group {
					nameLabel
					statusLabel
				}
				.multilineTextAlignment(.leading)
				.minimumScaleFactor(minimumScaleFactor)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding()
			.tint(container?.state.color ?? Container.State?.none.color)
			.contentTransition(.opacity)
			.modifier(LinkWrappedViewModifier(url: url))
			.background(Color.widgetBackground)
			.id("ContainerStatusWidgetView.ContainerView:\(container?.id ?? intentContainer._id)")
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerStatusWidget.ContainerView(entry: .placeholder, intentContainer: .preview())
}

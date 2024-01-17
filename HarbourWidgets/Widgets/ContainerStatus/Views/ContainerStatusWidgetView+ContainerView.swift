//
//  ContainerStatusWidgetView+ContainerView.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

// MARK: - ContainerStatusWidgetView+ContainerView

extension ContainerStatusWidgetView {
	struct ContainerView: View {
		var entry: ContainerStatusProvider.Entry
		var intentContainer: IntentContainer
		var container: Container?

		private let circleSize: Double = 8
		private let minimumScaleFactor: Double = 0.8

		private var url: URL? {
			guard !entry.isPlaceholder else { return nil }

			let deeplink = HarbourDeeplink.containerDetails(
				id: container?.id ?? intentContainer._id,
				displayName: container?.displayName ?? intentContainer.name,
				endpointID: entry.configuration.endpoint?.id
			)
			return deeplink.url ?? HarbourDeeplink.appURL
		}

		private var namePlaceholder: String {
			String(localized: "Generic.Unknown")
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

		@ViewBuilder
		private var stateHeadline: some View {
			HStack {
				Text(verbatim: (container?.state.description ?? ContainerState?.none.description).localizedCapitalized)
					.font(.subheadline)
					.fontWeight(.medium)
					.foregroundColor(container?.state.color ?? ContainerState?.none.color)
					.minimumScaleFactor(minimumScaleFactor)

				Spacer()

				Circle()
					.fill(container?.state.color ?? ContainerState?.none.color)
					.frame(width: circleSize, height: circleSize)
			}
		}

		@ViewBuilder
		private var dateLabel: some View {
			Text(entry.date, style: .relative)
				.font(.caption)
				.fontWeight(.medium)
				.foregroundStyle(.tertiary)
		}

		@ViewBuilder
		private var nameLabel: some View {
			let displayName = container?.displayName ?? intentContainer.name
			Text(verbatim: displayName ?? namePlaceholder)
				.font(.headline)
				.foregroundStyle(displayName != nil ? .primary : .secondary)
				.lineLimit(2)
		}

		@ViewBuilder
		private var statusLabel: some View {
			Text(verbatim: container?.status ?? statusPlaceholder)
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(container?.status != nil ? .secondary : .tertiary)
				.lineLimit(2)
		}

		var body: some View {
			VStack(spacing: 0) {
				stateHeadline
					.padding(.bottom, 2)

				dateLabel

				Spacer()

				Group {
					nameLabel
					statusLabel
				}
				.multilineTextAlignment(.leading)
				.minimumScaleFactor(minimumScaleFactor)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.contentTransition(.numericText())
			.padding()
			.modifier(LinkWrappedViewModifier(url: url))
			.background(Color.widgetBackground)
			.id("ContainerStatusWidgetView.ContainerView.\(container?.id ?? intentContainer._id)")
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerStatusWidgetView.ContainerView(entry: .placeholder, intentContainer: .preview())
}

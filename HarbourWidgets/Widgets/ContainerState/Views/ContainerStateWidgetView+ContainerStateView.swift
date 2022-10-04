//
//  ContainerStateWidgetView+ContainerStateView.swift
//  HarbourWidgets
//
//  Created by royal on 04/10/2022.
//

import SwiftUI
import WidgetKit
import PortainerKit

// MARK: - ContainerStateWidgetView+ContainerStateView

extension ContainerStateWidgetView {
	struct ContainerStateView: View {
		private static let circleSize: Double = 8
		private static let minimumScaleFactor: Double = 0.8

		let entry: ContainerStateProvider.Entry

		@ViewBuilder
		private var stateHeadline: some View {
			HStack {
				Text(entry.container?.state?.rawValue.capitalized ?? Localizable.ContainerCell.unknownState)
					.font(.subheadline.weight(.medium))
					.foregroundColor(entry.container?.state.color ?? ContainerState?.none.color)
//					.foregroundStyle(container.state != nil ? .secondary : .tertiary)
					.minimumScaleFactor(Self.minimumScaleFactor)

				Spacer()

				Circle()
					.fill(entry.container?.state.color ?? ContainerState?.none.color)
					.frame(width: Self.circleSize, height: Self.circleSize)
			}
		}

		@ViewBuilder
		private var dateLabel: some View {
			Text(entry.date, format: .dateTime)
				.font(.caption2.weight(.medium))
				.foregroundStyle(.tertiary)
				.frame(maxWidth: .infinity, alignment: .leading)
		}

		@ViewBuilder
		private var nameLabel: some View {
			let displayName = entry.container?.displayName ?? entry.configuration.container?.displayString ?? entry.configuration.container?.identifier
			Text(displayName ?? Localizable.Generic.unknown)
				.font(.headline)
				.foregroundStyle(displayName != nil ? .primary : .secondary)
		}

		@ViewBuilder
		private var statusLabel: some View {
			Text(entry.container?.status ?? Localizable.Widgets.unreachablePlaceholder)
				.font(.subheadline.weight(.medium))
				.foregroundStyle(entry.container?.status != nil ? .secondary : .tertiary)
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
				.lineLimit(2)
				.multilineTextAlignment(.leading)
				.minimumScaleFactor(Self.minimumScaleFactor)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding()
		}
	}
}

// MARK: - ContainerStateWidgetView.ContainerStateView+Components

private extension ContainerStateWidgetView.ContainerStateView {

}

// MARK: - Previews

// swiftlint:disable:next type_name
struct ContainerStateWidgetView_ContainerStateView_Previews: PreviewProvider {
	static let container = ContainerStateProvider.placeholderContainer
	static let entry = ContainerStateProvider.placeholderEntry

	static var previews: some View {
		ContainerStateWidgetView.ContainerStateView(entry: entry)
			.previewContext(WidgetPreviewContext(family: .systemSmall))
	}
}

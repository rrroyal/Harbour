//
//  ContainersGridView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersGridView+ContainerCell

extension ContainersGridView {
	struct ContainerCell: View {
		static let roundedRectangleBackground = RoundedRectangle(cornerRadius: Constants.ContainerCell.cornerRadius, style: .circular)

		private let minimumScaleFactor: Double = 0.7
		private let paddingSize: Double = 12

		let container: Container

		@ViewBuilder
		private var stateHeader: some View {
			HStack {
				Text(container._isStored ? ContainerState?.none.description : container.state.description.localizedCapitalized)
					.font(.footnote.weight(.medium))
					.foregroundStyle(.tint)
					.transition(.opacity)

				Spacer()

				Circle()
					.foregroundStyle(.tint)
					.frame(width: Constants.ContainerCell.circleSize, height: Constants.ContainerCell.circleSize)
					.transition(.opacity)
			}
			.animation(.easeInOut, value: container.state)
			.minimumScaleFactor(minimumScaleFactor)
		}

		@ViewBuilder
		private var nameAndStatusLabels: some View {
			VStack(alignment: .leading, spacing: 2) {
				Text(container.displayName ?? String(localized: "ContainerCell.UnknownName"))
					.font(.callout.weight(.semibold))
					.foregroundStyle(container.displayName != nil ? .primary : .secondary)
					.transition(.opacity)
					.lineLimit(2)

				Text(container.status ?? String(localized: "ContainerCell.UnknownStatus"))
					.font(.footnote.weight(.medium))
					.foregroundStyle(container.status != nil ? .secondary : .tertiary)
					.transition(.opacity)
					.lineLimit(2)
			}
			.foregroundStyle(Color.primary)
			.multilineTextAlignment(.leading)
			.minimumScaleFactor(minimumScaleFactor)
			.animation(.easeInOut, value: container.displayName)
			.animation(.easeInOut, value: container.status)
		}

		var body: some View {
			VStack(alignment: .leading) {
				stateHeader
				Spacer()
				nameAndStatusLabels
			}
			.padding(paddingSize)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.aspectRatio(1, contentMode: .fit)
			.tint(container._isStored ? ContainerState?.none.color : container.state.color)
			.background(Color.secondaryGroupedBackground)
			.contentShape(Self.roundedRectangleBackground)
			.clipShape(Self.roundedRectangleBackground)
			.animation(.easeInOut, value: container._isStored)
			.contentTransition(.opacity)
			.geometryGroup()
		}
	}
}

// MARK: - ContainersGridView.ContainerCell+Identifiable

extension ContainersGridView.ContainerCell: Identifiable {
	var id: String { container.id }
}

// MARK: - ContainersGridView.ContainerCell+Equatable

extension ContainersGridView.ContainerCell: Equatable {
	static func == (lhs: ContainersGridView.ContainerCell, rhs: ContainersGridView.ContainerCell) -> Bool {
		lhs.container._isStored == rhs.container._isStored &&
		lhs.container.state == rhs.container.state &&
		lhs.container.status == rhs.container.status &&
		lhs.container.displayName == rhs.container.displayName &&
		lhs.container.id == rhs.container.id
	}
}

// MARK: - Previews

#Preview {
	Button(action: {}) {
		ContainersGridView.ContainerCell(container: .preview)
	}
	.padding()
	.frame(width: 168, height: 168)
	.background(Color.groupedBackground)
	.previewLayout(.sizeThatFits)
}

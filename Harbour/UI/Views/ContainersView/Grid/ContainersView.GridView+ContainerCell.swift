//
//  ContainersView.GridView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView.GridView+ContainerCell

extension ContainersView.GridView {
	struct ContainerCell: View {
		static let roundedRectangleBackground = RoundedRectangle(cornerRadius: 18, style: .circular)

		@EnvironmentObject private var portainerStore: PortainerStore
		@ScaledMetric(relativeTo: .body) private var circleSize = 10
		private let minimumScaleFactor: Double = 0.7
		private let paddingSize: Double = 12

		var container: Container

		@MainActor
		private var isBeingRemoved: Bool {
			portainerStore.removedContainerIDs.contains(container.id)
		}

		@ViewBuilder @MainActor
		private var stateHeader: some View {
			HStack {
				Text(isBeingRemoved ? String(localized: "Generic.Removing") : (container._isStored ? Container.State?.none.description : container.state.description.localizedCapitalized))
					.font(.footnote)
					.fontWeight(.medium)
					.foregroundStyle(.tint)
					.lineLimit(1)

				Spacer()

				Image(systemName: "circle")
					.symbolVariant(isBeingRemoved ? .none : (container._isStored ? .none : .fill))
					.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isBeingRemoved)
					.imageScale(.small)
					.font(.system(size: circleSize))
					.fontWeight(.black)
					.foregroundStyle(.tint)
			}
			.minimumScaleFactor(minimumScaleFactor)
		}

		@ViewBuilder @MainActor
		private var nameAndStatusLabels: some View {
			VStack(alignment: .leading, spacing: 2) {
				Text(container.displayName ?? String(localized: "ContainerCell.UnknownName"))
					.font(.callout)
					.fontWeight(.semibold)
					.foregroundStyle(container.displayName != nil ? .primary : .secondary)
					.lineLimit(2)

				if !isBeingRemoved {
					Text(container.status ?? String(localized: "ContainerCell.UnknownStatus"))
						.font(.footnote)
						.fontWeight(.medium)
						.foregroundStyle(container.status != nil ? .secondary : .tertiary)
						.lineLimit(2)
				}
			}
			.foregroundStyle(Color.primary)
			.multilineTextAlignment(.leading)
			.minimumScaleFactor(minimumScaleFactor)
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
			.tint(isBeingRemoved ? .gray : (container._isStored ? Container.State?.none.color : container.state.color))
			.background(Color.secondaryGroupedBackground)
			.contentShape(Self.roundedRectangleBackground)
			.clipShape(Self.roundedRectangleBackground)
			.animation(.smooth, value: container)
			.animation(.smooth, value: container.state)
			.animation(.smooth, value: container.status)
			.animation(.smooth, value: isBeingRemoved)
		}
	}
}

// MARK: - ContainersView.GridView.ContainerCell+Identifiable

extension ContainersView.GridView.ContainerCell: Identifiable {
	var id: String { container.id }
}

// MARK: - ContainersView.GridView.ContainerCell+Equatable

extension ContainersView.GridView.ContainerCell: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.container._isStored == rhs.container._isStored &&
		lhs.container.state == rhs.container.state &&
		lhs.container.status == rhs.container.status &&
		lhs.container.displayName == rhs.container.displayName &&
		lhs.container.id == rhs.container.id
	}
}

// MARK: - Previews

#Preview("Cell") {
	Button(action: {}) {
		ContainersView.GridView.ContainerCell(container: .preview())
	}
	.padding()
	.frame(width: 168, height: 168)
	.background(Color.groupedBackground)
	.previewLayout(.sizeThatFits)
}

#Preview("Cell (Removed)") {
	Button(action: {}) {
		ContainersView.GridView.ContainerCell(container: .preview())
	}
	.padding()
	.frame(width: 168, height: 168)
	.background(Color.groupedBackground)
	.previewLayout(.sizeThatFits)
}

//
//  ContainersView.ListView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView.ListView+ContainerCell

extension ContainersView.ListView {
	struct ContainerCell: View {
		static let roundedRectangleBackground = RoundedRectangle(cornerRadius: 18, style: .circular)

		@EnvironmentObject private var portainerStore: PortainerStore
		@ScaledMetric(relativeTo: .body) private var circleSize = 12
		private let minimumScaleFactor: Double = 0.8

		let container: Container

		@MainActor
		private var tintColor: Color {
			isBeingRemoved ? .gray : (container._isStored ? Container.State?.none.color : container.state.color)
		}

		@MainActor
		private var isBeingRemoved: Bool {
			portainerStore.removedContainerIDs.contains(container.id)
		}

		@ViewBuilder @MainActor
		private var headlineLabel: some View {
			Text(container.displayName ?? String(localized: "ContainerCell.UnknownName"))
				.font(.headline)
				.fontWeight(.semibold)
				.foregroundStyle(container.displayName != nil ? .primary : .secondary)
				.tint(Color.primary)
		}

		@ViewBuilder @MainActor
		private var subheadlineLabel: some View {
			HStack(spacing: 4) {
				if isBeingRemoved {
					Text("Generic.Removing")
				} else {
					let stateLabel = container._isStored ? Container.State?.none.description : container.state.description.localizedCapitalized

					if let containerStatus = container.status {
						(
							Text(stateLabel).foregroundStyle(tintColor) +
							Text(verbatim: " • ").foregroundStyle(.secondary)
						) +
						Text(containerStatus)
							.foregroundStyle(.secondary)
					} else {
						Text(stateLabel)
							.foregroundStyle(.secondary)
					}
				}
			}
			.font(.subheadline)
			.fontWeight(.medium)
			.tint(isBeingRemoved ? tintColor : .primary)
		}

		var body: some View {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					headlineLabel
					subheadlineLabel
				}
				.minimumScaleFactor(minimumScaleFactor)

				Spacer(minLength: 20)

				Image(systemName: "circle")
					.symbolVariant(isBeingRemoved ? .none : (container._isStored ? .none : .fill))
					.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isBeingRemoved)
					.imageScale(.small)
					.font(.system(size: circleSize))
					.fontWeight(.black)
					.foregroundStyle(tintColor)
			}
			.padding()
			.lineLimit(1)
			.tint(isBeingRemoved ? .gray : (container._isStored ? Container.State?.none.color : container.state.color))
			.frame(maxWidth: .infinity)
			.background(Color.secondaryGroupedBackground)
			.contentShape(Self.roundedRectangleBackground)
			.clipShape(Self.roundedRectangleBackground)
			.animation(.smooth, value: container)
			.animation(.smooth, value: container.state)
			.animation(.smooth, value: container.status)
			.animation(.smooth, value: isBeingRemoved)
			.id(self.id)
		}
	}
}

// MARK: - ContainersView.ListView.ContainerCell+Identifiable

extension ContainersView.ListView.ContainerCell: Identifiable {
	nonisolated var id: String {
		"\(Self.self).\(container.id)"
	}
}

// MARK: - ContainersListView.ContainerCell+Equatable

extension ContainersView.ListView.ContainerCell: Equatable {
	nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
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
		ContainersView.ListView.ContainerCell(container: .preview())
	}
	.padding()
	.background(Color.groupedBackground)
	.previewLayout(.sizeThatFits)
}

#Preview("Cell (Removed)") {
	Button(action: {}) {
		ContainersView.ListView.ContainerCell(container: .preview())
	}
	.padding()
	.background(Color.groupedBackground)
	.previewLayout(.sizeThatFits)
}

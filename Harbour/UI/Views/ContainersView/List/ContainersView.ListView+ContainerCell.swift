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
		static let roundedRectangleBackground = RoundedRectangle(cornerRadius: Constants.ContainerCell.cornerRadius, style: .circular)

		private let minimumScaleFactor: Double = 0.8

		var container: Container

		@ViewBuilder
		private var headlineLabel: some View {
			Text(container.displayName ?? String(localized: "ContainerCell.UnknownName"))
				.font(.headline)
				.fontWeight(.semibold)
				.foregroundStyle(container.displayName != nil ? .primary : .secondary)
				.tint(Color.primary)
				.transition(.opacity)
				.animation(.easeInOut, value: container.displayName)
		}

		@ViewBuilder
		private var subheadlineLabel: some View {
			HStack(spacing: 4) {
				Text(container._isStored ? ContainerState?.none.description : container.state.description.localizedCapitalized)
					.foregroundStyle(.tint)
					.transition(.opacity)
					.animation(.easeInOut, value: container.state)
					.animation(.easeInOut, value: container._isStored)

				if let containerStatus = container.status {
					Group {
						Text(verbatim: "•")
						Text(containerStatus)
					}
					.foregroundStyle(.secondary)
					.tint(Color.primary)
				}
			}
			.font(.subheadline)
			.fontWeight(.medium)
			.transition(.opacity)
			.animation(.easeInOut, value: container.status)
		}

		var body: some View {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					headlineLabel
					subheadlineLabel
				}
				.minimumScaleFactor(minimumScaleFactor)

				Spacer()

				Circle()
					.foregroundStyle(.tint)
					.frame(width: Constants.ContainerCell.circleSize, height: Constants.ContainerCell.circleSize)
					.transition(.opacity)
					.animation(.easeInOut, value: container.state)
			}
			.padding()
			.lineLimit(1)
			.frame(maxWidth: .infinity)
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

// MARK: - ContainersView.ListView.ContainerCell+Identifiable

extension ContainersView.ListView.ContainerCell: Identifiable {
	var id: String { container.id }
}

// MARK: - ContainersListView.ContainerCell+Equatable

extension ContainersView.ListView.ContainerCell: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
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
		ContainersView.ListView.ContainerCell(container: .preview)
	}
	.padding()
	.background(Color.groupedBackground)
	.previewLayout(.sizeThatFits)
}

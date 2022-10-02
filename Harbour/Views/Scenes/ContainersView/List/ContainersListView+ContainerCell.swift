//
//  ContainersListView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainersListView+ContainerCell

extension ContainersListView {
	struct ContainerCell: View {
		private typealias Localization = Localizable.ContainerCell

		private static let minimumScaleFactor: Double = 0.8

		let container: Container

		private var subheadline: String? {
			let state = container.isStored ? Localization.unknownState : container.state?.rawValue.capitalized
			let parts = [state, container.status].compactMap { $0 }
			if !parts.isEmpty {
				return parts.joined(separator: Localization.stateJoiner)
			} else {
				return nil
			}
		}

		@ViewBuilder
		private var nameAndStatusLabels: some View {
			VStack(alignment: .leading, spacing: 2) {
				Text(container.displayName ?? Localization.unnamed)
					.font(.headline.weight(.semibold))
					.foregroundStyle(container.displayName != nil ? .primary : .secondary)
					.transition(.opacity)
					.animation(.easeInOut, value: container.displayName)

				Text(subheadline ?? Localization.unknownState)
					.font(.subheadline.weight(.medium))
					.foregroundStyle(subheadline != nil ? .secondary : .tertiary)
					.transition(.opacity)
					.animation(.easeInOut, value: subheadline)
			}
			.lineLimit(2)
			.multilineTextAlignment(.leading)
			.minimumScaleFactor(Self.minimumScaleFactor)
		}

		var body: some View {
			HStack {
				nameAndStatusLabels

				Spacer()

				Circle()
					.fill(container.isStored ? ContainerState?.none.color : container.state.color)
					.frame(width: Constants.ContainerCell.circleSize, height: Constants.ContainerCell.circleSize)
					.transition(.opacity)
					.animation(.easeInOut, value: container.state)
			}
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color(uiColor: .secondarySystemGroupedBackground))
			.cornerRadius(Constants.ContainerCell.cornerRadius)
		}
	}
}

// MARK: - ContainersListView.ContainerCell+Equatable

extension ContainersListView.ContainerCell: Equatable {
	static func == (lhs: ContainersListView.ContainerCell, rhs: ContainersListView.ContainerCell) -> Bool {
		lhs.container.id == rhs.container.id && lhs.container.state == rhs.container.state && lhs.container.status == rhs.container.status
	}
}

// MARK: - Previews

// swiftlint:disable:next type_name
struct ContainersListView_ContainerCell_Previews: PreviewProvider {
	static let container = Container(id: "id", names: ["PreviewContainer"], state: .running, status: "Status")
	static var previews: some View {
		ContainersListView.ContainerCell(container: container)
			.padding()
			.background(Color(uiColor: .systemGroupedBackground))
			.previewLayout(.sizeThatFits)
	}
}

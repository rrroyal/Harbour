//
//  ContainersGridView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainersGridView+ContainerCell

extension ContainersGridView {
	struct ContainerCell: View {
		private typealias Localization = Localizable.ContainerCell

		private static let minimumScaleFactor: Double = 0.6
		private static let paddingSize: Double = 12

		let container: Container

		@ViewBuilder
		private var stateHeader: some View {
			HStack {
				Text(container.isStored ? ContainerState?.none.description : container.state.description.capitalized)
					.font(.footnote.weight(.medium))
					.foregroundColor(container.isStored ? ContainerState?.none.color : container.state.color)
//					.foregroundStyle(container.state != nil ? .secondary : .tertiary)
					.transition(.opacity)

				Spacer()

				Circle()
					.fill(container.isStored ? ContainerState?.none.color : container.state.color)
					.frame(width: Constants.ContainerCell.circleSize, height: Constants.ContainerCell.circleSize)
					.transition(.opacity)
			}
			.animation(.easeInOut, value: container.state)
			.minimumScaleFactor(Self.minimumScaleFactor)
		}

		@ViewBuilder
		private var nameAndStatusLabels: some View {
			VStack(alignment: .leading, spacing: 2) {
				Text(container.displayName ?? Localization.unnamed)
					.font(.callout.weight(.semibold))
					.foregroundStyle(container.displayName != nil ? .primary : .secondary)
					.transition(.opacity)

				Text(container.status ?? Localizable.Generic.unknown)
					.font(.footnote.weight(.medium))
					.foregroundStyle(container.status != nil ? .secondary : .tertiary)
					.transition(.opacity)
			}
			.lineLimit(1)
			.multilineTextAlignment(.leading)
			.minimumScaleFactor(Self.minimumScaleFactor)
			.animation(.easeInOut, value: container.displayName)
			.animation(.easeInOut, value: container.status)
		}

		var body: some View {
			VStack(alignment: .leading) {
				stateHeader
				Spacer()
				nameAndStatusLabels
			}
			.padding(Self.paddingSize)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.aspectRatio(1, contentMode: .fit)
			.background(Color(uiColor: .secondarySystemGroupedBackground))
			.cornerRadius(Constants.ContainerCell.cornerRadius)
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
		lhs.container.id == rhs.container.id &&
		lhs.container.state == rhs.container.state &&
		lhs.container.status == rhs.container.status
	}
}

// MARK: - Previews

// swiftlint:disable:next type_name
struct ContainersGridView_ContainerCell_Previews: PreviewProvider {
	static let container = Container(id: "id", names: ["PreviewContainer"], state: .running, status: "Status")
	static var previews: some View {
		ContainersGridView.ContainerCell(container: container)
			.padding()
			.background(Color(uiColor: .systemGroupedBackground))
			.frame(width: 196, height: 196)
			.previewLayout(.sizeThatFits)
	}
}

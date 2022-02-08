//
//  ContainersListView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

extension ContainersListView {
	struct ContainerCell: View {
		@ObservedObject var container: PortainerKit.Container
		
		let circleSize: Double = 10
		static let backgroundShape = RoundedRectangle(cornerRadius: Constants.largeCornerRadius, style: .continuous)

		@ViewBuilder
		var containerStatusSubheadline: some View {
			Group {
				if let status = container.status,
				   let state = container.state?.rawValue.capitalizingFirstLetter,
				   status != state {
					Text("\(status) • \(state)")
						.foregroundStyle(.secondary)
				} else if let fallback = container.status ?? container.state?.rawValue.capitalizingFirstLetter {
					Text(fallback)
						.foregroundStyle(.secondary)
				} else {
					Text(Localization.Generic.unknown)
						.foregroundStyle(.tertiary)
				}
			}
			.font(.subheadline.weight(.medium))
			.lineLimit(1)
			.minimumScaleFactor(0.8)
			.multilineTextAlignment(.leading)
			.frame(maxWidth: .infinity, alignment: .leading)
			.id("ContainerCell.containerStatus:\(container.id)")
		}
		
		var body: some View {
			HStack {
				VStack(alignment: .leading, spacing: 5) {
					Text(container.displayName ?? container.id)
						.font(.headline)
						.foregroundColor(container.displayName != nil ? .primary : .secondary)
						.lineLimit(2)
						.minimumScaleFactor(0.6)
						.multilineTextAlignment(.leading)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					containerStatusSubheadline
				}
				
				Spacer()
				
				Circle()
					.fill(container.state.color)
					.frame(width: circleSize, height: circleSize)
					.animation(.easeInOut, value: container.state.color)
			}
			.padding()
			.background(ContainerCellBackground(state: container.state))
			.containerShape(Self.backgroundShape)
			.animation(.easeInOut, value: container.state)
			.animation(.easeInOut, value: container.status)
			.animation(.easeInOut, value: container.displayName)
			.transition(.opacity)
		}
	}
}

extension ContainersListView.ContainerCell: Identifiable, Equatable {
	var id: String { container.id }
	
	static func == (lhs: ContainersListView.ContainerCell, rhs: ContainersListView.ContainerCell) -> Bool {
		lhs.container.id == rhs.container.id &&
		lhs.container.status == rhs.container.status &&
		lhs.container.state == rhs.container.state &&
		lhs.container.displayName == rhs.container.displayName
	}
}

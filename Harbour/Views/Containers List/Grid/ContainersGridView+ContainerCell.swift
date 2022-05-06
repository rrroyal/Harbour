//
//  ContainersGridView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

extension ContainersGridView {
	struct ContainerCell: View {
		@ObservedObject var container: PortainerKit.Container
		
		let circleSize: Double = 8
		static let backgroundShape = RoundedRectangle(cornerRadius: Constants.largeCornerRadius, style: .continuous)
		
		var body: some View {
			VStack {
				HStack(alignment: .center) {
					Text(container.state?.rawValue.capitalizingFirstLetter() ?? Localization.Generic.unknown)
						.font(.footnote.weight(.medium))
						.foregroundStyle(container.state != nil ? .secondary : .tertiary)
						.lineLimit(1)
						.frame(maxWidth: .infinity, alignment: .leading)
						.animation(.easeInOut, value: container.state)
					
					Spacer()
					
					Circle()
						.fill(container.state.color)
						.frame(width: circleSize, height: circleSize)
						.animation(.easeInOut, value: container.state.color)
				}
				
				Spacer()
				
				if let status = container.status {
					Text(status)
						.font(.caption.weight(.medium))
						.foregroundStyle(.secondary)
						.lineLimit(1)
						.minimumScaleFactor(0.8)
						.multilineTextAlignment(.leading)
						.frame(maxWidth: .infinity, alignment: .leading)
						.id("ContainerCell.containerStatus:\(container.id)")
				}
				
				Text(container.displayName ?? container.id)
					.font(.headline)
					.foregroundColor(container.displayName != nil ? .primary : .secondary)
					.lineLimit(2)
					.minimumScaleFactor(0.6)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding(.medium)
			.aspectRatio(1, contentMode: .fill)
			.background(Color(uiColor: .systemBackground))
			.containerShape(Self.backgroundShape)
			.animation(.easeInOut, value: container.status)
			.animation(.easeInOut, value: container.displayName)
			.transition(.opacity)
		}
	}
}

extension ContainersGridView.ContainerCell: Identifiable, Equatable {
	var id: String { container.id }
	
	static func == (lhs: ContainersGridView.ContainerCell, rhs: ContainersGridView.ContainerCell) -> Bool {
		lhs.container.id == rhs.container.id &&
		lhs.container.status == rhs.container.status &&
		lhs.container.state == rhs.container.state &&
		lhs.container.displayName == rhs.container.displayName
	}
}

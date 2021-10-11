//
//  ContainerListView+ContainerCell.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

extension ContainerListView {
	struct ContainerCell: View {
		@ObservedObject var container: PortainerKit.Container
		
		let circleSize: Double = 10
		let backgroundRectangle: some Shape = RoundedRectangle(cornerRadius: Globals.Views.largeCornerRadius, style: .continuous)

		@ViewBuilder
		var containerStatusSubheadline: some View {
			Group {
				if let status = container.status,
				   let state = container.state {
					Text("\(status) • \(state.rawValue.capitalizingFirstLetter())")
				} else if let fallback = container.status ?? container.state?.rawValue.capitalizingFirstLetter() {
					Text(fallback)
				}
			}
			.font(.subheadline.weight(.medium))
			.foregroundStyle(.secondary)
			.lineLimit(1)
			.minimumScaleFactor(0.8)
			.multilineTextAlignment(.leading)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		
		var body: some View {
			HStack {
				VStack(alignment: .leading, spacing: 5) {
					Text(container.displayName ?? "Unnamed")
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
			.background(Color(uiColor: .secondarySystemBackground), in: backgroundRectangle)
			.contentShape(backgroundRectangle)
			.animation(.easeInOut, value: container.state)
			.animation(.easeInOut, value: container.status)
			.animation(.easeInOut, value: container.displayName)
			.transition(.opacity)
		}
	}
}

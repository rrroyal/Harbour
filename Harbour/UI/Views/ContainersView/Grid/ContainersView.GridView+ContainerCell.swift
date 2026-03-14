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
		@EnvironmentObject private var portainerStore: PortainerStore
		@ScaledMetric(relativeTo: .body) private var circleSize = 10
		@State private var stats: ContainerStats?
		private let minimumScaleFactor: Double = 0.7
		private let paddingSize: Double = 12
		private let background = RoundedRectangle(cornerRadius: 18, style: .circular)

		let container: Container

		@MainActor
		private var isBeingRemoved: Bool {
			portainerStore.removedContainerIDs.contains(container.id)
		}

		@MainActor
		private var isRunning: Bool {
			container.state == .running
		}

		@ViewBuilder @MainActor
		private var stateHeader: some View {
			HStack {
				Text(isBeingRemoved ? String(localized: "Generic.Removing") : (container._isStored ? Container.State?.none : container.state).title)
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

		@ViewBuilder @MainActor
		private var statsLabels: some View {
			if isRunning, let stats {
				HStack(spacing: 6) {
					if let cpu = stats.cpuUsagePercent {
						Label {
							Text(cpu, format: .number.precision(.fractionLength(1)))
								+ Text("%")
						} icon: {
							Image(systemName: "cpu")
						}
					}

					if let mem = stats.memoryUsageBytes, let limit = stats.memoryLimitBytes, limit > 0 {
						let memMiB = Double(mem) / 1_048_576
						Label {
							if memMiB >= 1024 {
								Text(memMiB / 1024, format: .number.precision(.fractionLength(1)))
									+ Text("G")
							} else {
								Text(memMiB, format: .number.precision(.fractionLength(0)))
									+ Text("M")
							}
						} icon: {
							Image(systemName: "memorychip")
						}
					}
				}
				.labelStyle(.titleAndIcon)
				.font(.system(size: 9, weight: .medium))
				.foregroundStyle(.secondary)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			}
		}

		var body: some View {
			VStack(alignment: .leading) {
				stateHeader
				Spacer()
				nameAndStatusLabels
				statsLabels
			}
			.padding(paddingSize)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.aspectRatio(1, contentMode: .fit)
			.tint(isBeingRemoved ? .gray : (container._isStored ? Container.State?.none.color : container.state.color))
			#if os(iOS)
			.background(Color.secondaryGroupedBackground, in: background)
			#elseif os(macOS)
			.background(.regularMaterial, in: background)
			.background(Color(nsColor: .windowBackgroundColor).opacity(0.1), in: background)
			#endif
			.contentShape(background)
			#if os(iOS)
			.contentShape(.contextMenuPreview, background)
			#endif
			.animation(.default, value: container)
			.animation(.default, value: container.state)
			.animation(.default, value: container.status)
			.animation(.default, value: isBeingRemoved)
			.animation(.default, value: stats?.cpuUsagePercent)
			.id(self.id)
			.task(id: container.id) {
				guard isRunning else {
					stats = nil
					return
				}
				stats = try? await portainerStore.fetchContainerStats(container.id)
			}
		}
	}
}

// MARK: - ContainersView.GridView.ContainerCell+Identifiable

extension ContainersView.GridView.ContainerCell: Identifiable {
	nonisolated var id: String {
		"\(Self.self).\(container.id)"
	}
}

// MARK: - ContainersView.GridView.ContainerCell+Equatable

extension ContainersView.GridView.ContainerCell: @MainActor Equatable {
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
}

#Preview("Cell (Removed)") {
	Button(action: {}) {
		ContainersView.GridView.ContainerCell(container: .preview())
	}
	.padding()
	.frame(width: 168, height: 168)
	.background(Color.groupedBackground)
}

//
//  StacksView+StackCell.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - StacksView+StackCell

extension StacksView {
	struct StackCell: View {
		let stack: Stack
		let containers: [Container]
		let isLoading: Bool
		let filterAction: () -> Void
		let toggleAction: () -> Void

		init(
			_ stack: Stack,
			containers: [Container],
			isLoading: Bool,
			filterAction: @escaping () -> Void,
			toggleAction: @escaping () -> Void
		) {
			self.stack = stack
			self.containers = containers
			self.isLoading = isLoading
			self.filterAction = filterAction
			self.toggleAction = toggleAction
		}

		@ScaledMetric(relativeTo: .subheadline)
		private var iconSize = 6

		private var isOn: Bool {
			stack.status == .active
		}

		private var stackColor: Color {
			if isLoading { return Color.gray }
			if !isOn { return stack.status.color.opacity(Constants.secondaryOpacity) }

			if containers.count == runningContainersCount {
				return stack.status.color
			} else {
				let hasFailedContainers = containers.contains {
					if let exitCode = $0.exitCode {
						return exitCode != 0
					}
					return false
				}
				return hasFailedContainers ? Color.orange : stack.status.color
			}
		}

		private var runningContainersCount: Int {
			containers.filter { $0.state.isRunning }.count
		}

		var body: some View {
			NavigationLink(value: StackDetailsView.NavigationItem(stackID: stack.id)) {
				VStack(alignment: .leading) {
					Text(verbatim: stack.name)
						.font(.body)
						.fontWeight(.medium)
						.foregroundStyle(isOn ? Color.primary : Color.secondary)

					HStack(spacing: 4) {
						Image(systemName: "circle")
							.font(.system(size: iconSize))
							.accessibilityLabel(isLoading ? String(localized: "Generic.Loading") : stack.status.title)

						Group {
							if isLoading {
								Text("Generic.Loading")
							} else {
								if isOn {
									Text(verbatim: "\(stack.status.title) (\(runningContainersCount)/\(containers.count))")
								} else {
									Text(verbatim: stack.status.title)
								}
							}
						}
						.font(.footnote)
						.fontWeight(.medium)
					}
					.foregroundStyle(stackColor)
					.symbolVariant(isLoading ? .none : .fill)
					.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isLoading)
				}
			}
			#if os(macOS)
			.buttonStyle(.fadesOnPress)
			#endif
			.padding(.vertical, 2)
			.transition(.opacity)
			.animation(.easeInOut, value: isLoading)
			.animation(.easeInOut, value: stack.status)
			.contextMenu {
				StackToggleButton(stack: stack, toggleAction: toggleAction)
					.disabled(isLoading)
			}
			.swipeActions(edge: .leading) {
				FilterButton(stack: stack, filterAction: filterAction)
					.tint(Color.accentColor)
			}
			.swipeActions(edge: .trailing) {
				StackToggleButton(stack: stack, toggleAction: toggleAction)
					.tint(isOn ? .red : .green)
					.disabled(isLoading)
			}
		}
	}
}

// MARK: - StacksView.StackCell+StackToggleButton

private extension StacksView.StackCell {
	struct StackToggleButton: View {
		let stack: Stack
		let toggleAction: () -> Void

		var body: some View {
			Button(action: toggleAction) {
				Label(
					stack.isOn ? "StacksView.Stack.Stop" : "StacksView.Stack.Start",
					systemImage: stack.isOn ? SFSymbol.stop : SFSymbol.start
				)
			}
			.symbolVariant(.fill)
			.labelStyle(.titleAndIcon)
		}
	}
}

// MARK: - StacksView.StackCell+FilterButton

private extension StacksView.StackCell {
	struct FilterButton: View {
		let stack: Stack
		let filterAction: () -> Void

		var body: some View {
			Button(action: filterAction) {
				Label("StacksView.ShowContainers", systemImage: SFSymbol.container)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	StacksView.StackCell(.preview, containers: [.preview], isLoading: false, filterAction: { }, toggleAction: { })
}

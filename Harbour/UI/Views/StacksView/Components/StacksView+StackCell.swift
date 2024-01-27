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
		@Environment(\.portainerServerURL) private var portainerServerURL
		var stack: StackItem
		var containers: [Container]
		var isLoading: Bool
		var filterAction: () -> Void
		var toggleAction: () -> Void

		init(
			_ stack: StackItem,
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
			stack.stack?.isOn ?? true
		}

		private var stackColor: Color {
			guard let stack = stack.stack else { return .orange }
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
				return hasFailedContainers ? Color.purple : stack.status.color
			}
		}

		private var stackStatusLabel: String {
			guard let stack = stack.stack else { return String(localized: "StacksView.Stack.Limited") }
			return stack.status.title
		}

		private var runningContainersCount: Int {
			containers.filter { $0.state.isRunning }.count
		}

		var body: some View {
			VStack(alignment: .leading) {
				Text(verbatim: stack.name)
					.font(.body)
					.fontWeight(.medium)
					.foregroundStyle(isOn ? Color.primary : Color.secondary)

				HStack(spacing: 4) {
					Image(systemName: "circle")
						.font(.system(size: iconSize))
						.accessibilityLabel(isLoading ? String(localized: "Generic.Loading") : stackStatusLabel)

					Group {
						if isLoading {
							Text("Generic.Loading")
						} else {
							if isOn {
								Text(verbatim: "\(stackStatusLabel) (\(runningContainersCount)/\(containers.count))")
							} else {
								Text(verbatim: stackStatusLabel)
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
			.padding(.vertical, 2)
			.transition(.opacity)
			.animation(.easeInOut, value: isLoading)
			.animation(.easeInOut, value: stack.stack?.status)
			.contextMenu {
				if let stack = stack.stack {
					StackToggleButton(stack: stack, toggleAction: toggleAction)
						.disabled(isLoading)

					Divider()

					if let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)?.stackURL(stack: stack) {
						ShareLink("Generic.SharePortainerURL", item: portainerDeeplink)
					}
				}
			}
			.swipeActions(edge: .leading) {
				FilterButton(filterAction: filterAction)
					.tint(Color.accentColor)
			}
			.swipeActions(edge: .trailing) {
				if let stack = stack.stack {
					StackToggleButton(stack: stack, toggleAction: toggleAction)
						.tint(isOn ? .red : .green)
						.disabled(isLoading)
				}
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
	StacksView.StackCell(.init(stack: .preview), containers: [.preview], isLoading: false, filterAction: { }, toggleAction: { })
}

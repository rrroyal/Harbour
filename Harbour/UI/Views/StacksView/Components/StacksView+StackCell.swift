//
//  StacksView+StackCell.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - StacksView+StackCell

extension StacksView {
	struct StackCell: View {
		@EnvironmentObject private var portainerStore: PortainerStore
		@Environment(\.portainerServerURL) private var portainerServerURL
		var stack: StackItem
		var containers: [Container]
		var isLoading: Bool
		var filterAction: () -> Void
		var setStackStateAction: (Bool) -> Void
		var removeStackAction: () -> Void

		init(
			_ stack: StackItem,
			containers: [Container],
			isLoading: Bool,
			filterAction: @escaping () -> Void = { },
			setStackStateAction: @escaping (Bool) -> Void = { _ in },
			removeStackAction: @escaping () -> Void = { }
		) {
			self.stack = stack
			self.containers = containers
			self.isLoading = isLoading
			self.filterAction = filterAction
			self.setStackStateAction = setStackStateAction
			self.removeStackAction = removeStackAction
		}

		@MainActor
		private var isBeingRemoved: Bool {
			if let stackID = Stack.ID(stack.id) {
				portainerStore.removedStackIDs.contains(stackID)
			} else {
				false
			}
		}

		@ScaledMetric(relativeTo: .subheadline)
		private var iconSize = 6

		private var isOn: Bool {
			stack.stack?.isOn ?? true
		}

		private var stackColor: Color {
			if isLoading || isBeingRemoved { return .gray }

			let containersCount = containers.count
			if containersCount == runningContainersCount, containersCount > 0 {
				return Stack.Status.active.color
			}

			let hasFailedContainers = containers.contains {
				(($0.exitCode ?? 0) != 0) || $0.state == .dead
			}
			if hasFailedContainers {
				return .orange
			}

			if let stack = stack.stack {
				return stack.status.color
			}

			return .gray
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
					.font(.headline)
					.fontWeight(.medium)

				HStack(spacing: 4) {
					Image(systemName: "circle")
						.font(.system(size: iconSize))
						.fontWeight(.black)
						.symbolVariant(isLoading ? .none : .fill)
						.symbolVariant(isBeingRemoved ? .none : .fill)
						.symbolVariant(stack.stack?._isStored ?? false ? .none : .fill)

					Group {
						if isLoading {
							Text("Generic.Loading")
						} else if isBeingRemoved {
							Text("Generic.Removing")
						} else {
							Text(verbatim: isOn ? "\(stackStatusLabel) (\(runningContainersCount)/\(containers.count))" : stackStatusLabel)
						}
					}
					.font(.footnote)
					.fontWeight(.medium)
					.transition(.opacity)
					.id(ViewID.subheadlineLabel)
				}
				.foregroundStyle(stackColor)
				.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isLoading || isBeingRemoved)
				.transition(.opacity)
			}
			.padding(.vertical, 2)
			.transition(.opacity)
			.animation(.easeInOut, value: stack.stack?.status)
			.animation(.easeInOut, value: isLoading)
			.animation(.easeInOut, value: isOn)
			.animation(.easeInOut, value: isBeingRemoved)
			.contextMenu {
				if let stack = stack.stack {
					StackContextMenu(stack: stack) {
						setStackStateAction($0)
					} removeStackAction: {
						removeStackAction()
					}
				}
			}
			.swipeActions(edge: .leading) {
				if isOn {
					FilterButton(filterAction: filterAction)
						.tint(.accent)
				}
			}
			.swipeActions(edge: .trailing) {
				if let stack = stack.stack {
					StackToggleButton(stack: stack) {
						setStackStateAction(!stack.isOn)
					}
					.tint(isLoading ? .gray : (isOn ? .red : .green))
					.disabled(isLoading)
				}
			}
			.id("StackCell.\(stack.id)")
		}
	}
}

// MARK: - StacksView.StackCell+ViewID

private extension StacksView.StackCell {
	enum ViewID {
		case subheadlineLabel
	}
}

// MARK: - StacksView.StackCell+StackToggleButton

private extension StacksView.StackCell {
	struct StackToggleButton: View {
		let stack: Stack
		let toggleAction: () -> Void

		var body: some View {
			Button {
				Haptics.generateIfEnabled(.light)
				toggleAction()
			} label: {
				Label(
					stack.isOn ? "StacksView.Stack.Stop" : "StacksView.Stack.Start",
					systemImage: stack.isOn ? SFSymbol.stop : SFSymbol.start
				)
			}
//			.symbolVariant(.fill)
//			.labelStyle(.titleAndIcon)
		}
	}
}

// MARK: - StacksView.StackCell+FilterButton

private extension StacksView.StackCell {
	struct FilterButton: View {
		let filterAction: () -> Void

		var body: some View {
			Button {
				Haptics.generateIfEnabled(.light)
				filterAction()
			} label: {
				Label("StacksView.ShowContainers", image: SFSymbol.Custom.container)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	List {
		StacksView.StackCell(.init(stack: .preview()), containers: [.preview()], isLoading: false)
		StacksView.StackCell(.init(stack: .preview()), containers: [.preview(), .preview(state: .dead)], isLoading: false)
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
		StacksView.StackCell(.init(label: "LimitedStack"), containers: [.preview()], isLoading: false)
		StacksView.StackCell(.init(label: "LimitedStack"), containers: [.preview(), .preview(state: .dead)], isLoading: false)
	}
}

#Preview {
	List {
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
			.redacted(reason: .placeholder)
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
			.redacted(reason: .placeholder)
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
			.redacted(reason: .placeholder)
		StacksView.StackCell(.init(stack: .preview(name: "Stacks", status: .active)), containers: [.preview()], isLoading: false)
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
			.redacted(reason: .placeholder)
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
			.redacted(reason: .placeholder)
		StacksView.StackCell(.init(stack: .preview(status: .inactive)), containers: [], isLoading: false)
			.redacted(reason: .placeholder)
	}
}

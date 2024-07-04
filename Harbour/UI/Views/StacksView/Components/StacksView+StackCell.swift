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
		@Environment(SceneDelegate.self) private var sceneDelegate
		var stack: StackItem
		var containers: [Container]
		var filterAction: () -> Void
		var setStackStateAction: (Bool) -> Void

		@ScaledMetric(relativeTo: .subheadline)
		private var iconSize = 6

		init(
			_ stack: StackItem,
			containers: [Container],
			filterAction: @escaping () -> Void,
			setStackStateAction: @escaping (Bool) -> Void
		) {
			self.stack = stack
			self.containers = containers
			self.filterAction = filterAction
			self.setStackStateAction = setStackStateAction
		}

		private var isBeingRemoved: Bool {
			if let stackID = Stack.ID(stack.id) {
				portainerStore.removedStackIDs.contains(stackID)
			} else {
				false
			}
		}

		private var isLoading: Bool {
			portainerStore.loadingStackIDs.contains(Stack.ID(stack.id) ?? -1)
		}

		private var isOn: Bool {
			stack.stack?.isOn ?? true
		}

		private var stackColor: Color {
			if stack.stack?._isStored ?? false || isLoading || isBeingRemoved { return .gray }

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
			containers.count { $0.state.isRunning }
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
						if isBeingRemoved {
							Text("Generic.Removing")
						} else if isLoading {
							Text("Generic.Loading")
						} else {
							let runningContainersCount = self.runningContainersCount
							let containersCount = self.containers.count
							let showContainerCount = isOn && containersCount > 0
							Text(verbatim: showContainerCount ? "\(stackStatusLabel) (\(runningContainersCount)/\(containersCount))" : stackStatusLabel)
						}
					}
					.font(.footnote)
					.fontWeight(.medium)
					.id(ViewID.subheadlineLabel)
				}
				.foregroundStyle(stackColor)
				.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isLoading || isBeingRemoved)
			}
			.padding(.vertical, 2)
			.animation(.default, value: stack)
			.animation(.default, value: stack.stack?.status)
			.animation(.default, value: stack.stack?._isStored)
			.animation(.default, value: isLoading)
			.animation(.default, value: isOn)
			.animation(.default, value: isBeingRemoved)
			.contextMenu {
				if let stack = stack.stack {
					StackContextMenu(
						stack: stack,
						setStackStateAction: { setStackStateAction($0) }
					)
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
					systemImage: stack.isOn ? Stack.Status.inactive.icon : Stack.Status.active.icon
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
		StacksView.StackCell(
			.init(stack: .preview()),
			containers: [.preview()],
			filterAction: { },
			setStackStateAction: { _ in }
		)
		StacksView.StackCell(
			.init(stack: .preview()),
			containers: [.preview(), .preview(state: .dead)],
			filterAction: { },
			setStackStateAction: { _ in }
		)
		StacksView.StackCell(
			.init(stack: .preview(status: .inactive)),
			containers: [],
			filterAction: { },
			setStackStateAction: { _ in }
		)
		StacksView.StackCell(
			.init(label: "LimitedStack"),
			containers: [.preview()],
			filterAction: { },
			setStackStateAction: { _ in }
		)
		StacksView.StackCell(
			.init(label: "LimitedStack"),
			containers: [.preview(), .preview(state: .dead)],
			filterAction: { },
			setStackStateAction: { _ in }
		)
	}
}

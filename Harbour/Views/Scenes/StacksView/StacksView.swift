//
//  StacksView.swift
//  Harbour
//
//  Created by royal on 31/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - StacksView

struct StacksView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()

	let stackTappedAction: (Stack) -> Void

	var body: some View {
		List {
			if let stacks = viewModel.stacks {
				ForEach(stacks) { stack in
					let isLoading = viewModel.loadingStacks.contains(stack.id)
					let isStackOn = stack.status == .active
					let containers = portainerStore.containers.filter { $0.stack == stack.name }

					StackCell(stack, containers: containers, isLoading: isLoading) {
						stackTappedAction(stack)
						dismiss()
					} toggleAction: {
						setStackState(stack, started: !isStackOn)
					}
					.transition(.opacity)
				}
			}
		}
		.searchable(text: $viewModel.searchText)
		.overlay(viewModel.viewState.backgroundView)
		.overlay {
			if viewModel.shouldShowEmptyPlaceholderView {
				if !viewModel.searchText.isEmpty {
					ContentUnavailableView.search(text: viewModel.searchText)
				} else {
					ContentUnavailableView("StacksView.NoContainersPlaceholder", systemImage: SFSymbol.xmark)
				}
			}
		}
		.navigationTitle("StacksView.Title")
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.viewState.id)
		.animation(.easeInOut, value: viewModel.stacks)
		.task {
			do {
				try await viewModel.getStacks()
			} catch {
				errorHandler(error)
			}
		}
		.refreshable {
			do {
				try await viewModel.getStacks()
			} catch {
				errorHandler(error)
			}
		}
	}

	private func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				Haptics.generateIfEnabled(.light)
				try await viewModel.setStackState(stack, started: started)
			} catch {
				errorHandler(error)
			}
		}
	}
}

// MARK: - StacksView+StackCell

private extension StacksView {
	struct StackCell: View {
		let stack: Stack
		let containers: [Container]
		let isLoading: Bool
		let tappedAction: () -> Void
		let toggleAction: () -> Void

		init(
			_ stack: Stack,
			containers: [Container],
			isLoading: Bool,
			tappedAction: @escaping () -> Void,
			toggleAction: @escaping () -> Void
		) {
			self.stack = stack
			self.containers = containers
			self.isLoading = isLoading
			self.tappedAction = tappedAction
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
					if let exitCode = $0._exitCode {
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
			Button(action: tappedAction) {
				HStack {
					VStack(alignment: .leading) {
						Text(verbatim: stack.name)
							.font(.body)
							.fontWeight(.medium)

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

					Spacer()

					Image(systemName: SFSymbol.filter)
						.tint(Color.accentColor)
				}
			}
			.disabled(!isOn || isLoading)
			.tint(Color.primary)
			.padding(.vertical, 2)
			.transition(.opacity)
			.animation(.easeInOut, value: isLoading)
			.animation(.easeInOut, value: stack.status)
			.contextMenu {
				StacksView.StackToggleButton(stack: stack, toggleAction: toggleAction)
					.disabled(isLoading)
			}
			.swipeActions(edge: .trailing) {
				StacksView.StackToggleButton(stack: stack, toggleAction: toggleAction)
					.tint(isOn ? .red : .green)
					.disabled(isLoading)
			}
		}
	}
}

// MARK: - StacksView+StackToggleButton

private extension StacksView {
	struct StackToggleButton: View {
		let stack: Stack
		let toggleAction: () -> Void

		var body: some View {
			Button {
				toggleAction()
			} label: {
				if stack.status == .active {
					Label("StacksView.Stack.Stop", systemImage: SFSymbol.stop)
				} else {
					Label("StacksView.Stack.Start", systemImage: SFSymbol.start)
				}
			}
			.symbolVariant(.fill)
		}
	}
}

// MARK: - Previews

#Preview("StacksView") {
	StacksView(stackTappedAction: { _ in })
		.environmentObject(PortainerStore.shared)
}

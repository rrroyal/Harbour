//
//  StacksView.swift
//  Harbour
//
//  Created by royal on 31/01/2023.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - StacksView

struct StacksView: View {
	@Environment(\.errorHandler) var errorHandler
	@StateObject private var viewModel = ViewModel()

	var body: some View {
		List {
			if let stacks = viewModel.stacks {
				ForEach(stacks) { stack in
					let isLoading = viewModel.loadingStacks.contains(stack.id)
					let isStackOn = stack.status == .active
					StackCell(stack: stack, isOn: isStackOn, isLoading: isLoading) {
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
		let isOn: Bool
		let isLoading: Bool
		let toggleAction: () -> Void

		@ScaledMetric(relativeTo: .subheadline)
		private var iconSize = 6

		var body: some View {
			NavigationLink {
				ContainersList(stack: stack)
			} label: {
				VStack(alignment: .leading) {
					Text(stack.name)
						.font(.body)
						.fontWeight(.medium)

					HStack(spacing: 4) {
						Image(systemName: "circle")
							.symbolVariant(isLoading ? .none : .fill)
							.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isLoading)
							.font(.system(size: iconSize))
							.foregroundStyle(isLoading ? Color.gray : stack.status.color)
							.accessibilityLabel(isLoading ? "Generic.Loading" : stack.status.label)

						Text(isLoading ? "Generic.Loading" : stack.status.label)
							.font(.footnote)
							.fontWeight(.medium)
							.foregroundStyle(isLoading ? Color.gray : stack.status.color)
					}
					.transition(.opacity)
				}
			}
			.disabled(!isOn)
			.padding(.vertical, 2)
			.transition(.opacity)
			.animation(.easeInOut, value: isLoading)
			.animation(.easeInOut, value: stack.status)
			.contextMenu {
				StackToggleButton(stack: stack, isOn: isOn, toggleAction: toggleAction)
					.disabled(isLoading)
			}
			.swipeActions(edge: .trailing) {
				StackToggleButton(stack: stack, isOn: isOn, toggleAction: toggleAction)
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
		let isOn: Bool
		let toggleAction: () -> Void

		var body: some View {
			Button {
				toggleAction()
			} label: {
				if isOn {
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

/*
#Preview("StacksView") {
	StacksView()
}
*/

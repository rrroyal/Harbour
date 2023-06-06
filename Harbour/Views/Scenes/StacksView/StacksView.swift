//
//  StacksView.swift
//  Harbour
//
//  Created by royal on 31/01/2023.
//

import SwiftUI
import CommonHaptics
import PortainerKit

// MARK: - StacksView

struct StacksView: View {
	private typealias Localization = Localizable.StacksView

	@Environment(\.errorHandler) var errorHandler
	@StateObject private var viewModel = ViewModel()

	var body: some View {
		List {
			if let stacks = viewModel.viewState.unwrappedValue {
				ForEach(stacks.filtered(viewModel.searchText)) { stack in
					let isLoading = viewModel.loadingStacks.contains(stack.id)
					let isStackOn = stack.status == .active
					StackCell(stack: stack, isOn: isStackOn, isLoading: isLoading) {
						setStackStatus(stack, started: !isStackOn)
					}
				}
			}
		}
		.searchable(text: $viewModel.searchText)
		.background(viewModel.viewState.backgroundView())
		.navigationTitle(Localization.title)
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.viewState.id)
		.task {
			await viewModel.getStacks(errorHandler: errorHandler)
		}
		.refreshable {
			await viewModel.getStacks(errorHandler: errorHandler)
		}
	}

	private func setStackStatus(_ stack: Stack, started: Bool) {
		Task {
			Haptics.generateIfEnabled(.light)
			await viewModel.setStackStatus(stack, started: started, errorHandler: errorHandler)
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
						Image(systemName: SFSymbol.circle)
							.symbolVariant(isLoading ? .none : .fill)
							.symbolEffect(.pulse, options: .repeating.speed(1.5), isActive: isLoading)
							.font(.system(size: iconSize))
							.foregroundStyle(isLoading ? Color.gray : stack.status.color)
							.accessibilityLabel(isLoading ? Localizable.Generic.loading : stack.status.label)

						Text(isLoading ? Localizable.Generic.loading : stack.status.label)
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
				Group {
					if isOn {
						Label(Localization.Stack.stop, systemImage: SFSymbol.disable)
					} else {
						Label(Localization.Stack.start, systemImage: SFSymbol.enable)
					}
				}
				.symbolVariant(.fill)
			}
		}
	}
}

// MARK: - Previews

#Preview("StacksView") {
	StacksView()
}

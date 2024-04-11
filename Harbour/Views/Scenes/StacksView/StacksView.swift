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
	@Binding var selectedStack: Stack?

	@ViewBuilder
	private var placeholderView: some View {
		if viewModel.shouldShowEmptyPlaceholderView {
			if !viewModel.searchText.isEmpty {
				ContentUnavailableView.search(text: viewModel.searchText)
			} else {
				ContentUnavailableView("StacksView.NoContainersPlaceholder", systemImage: SFSymbol.xmark)
			}
		}
	}

	var body: some View {
		NavigationStack {
			Form {
				if let stacks = viewModel.stacksFiltered {
					ForEach(stacks) { stack in
						let isLoading = viewModel.loadingStacks.contains(stack.id)
						let containers = portainerStore.containers.filter { $0.stack == stack.name }

						StackCell(stack, containers: containers, isLoading: isLoading) {
							selectedStack = stack
							dismiss()
						} toggleAction: {
							setStackState(stack, started: !stack.isOn)
						}
						.transition(.opacity)
					}
				}
			}
			.formStyle(.grouped)
			.searchable(text: $viewModel.searchText)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			#if os(macOS)
			.frame(minWidth: Constants.Window.minWidth, minHeight: Constants.Window.minHeight)
			#endif
			.background {
				placeholderView
			}
			.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
			.navigationTitle("StacksView.Title")
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .cancellationAction) {
					CloseButton {
						dismiss()
					}
				}
				#endif
			}
			.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
				StackDetailsView(navigationItem: navigationItem, selectedStack: $selectedStack)
					.environment(viewModel)
			}
		}
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.viewState.id)
		.animation(.easeInOut, value: viewModel.stacks)
		.scrollDismissesKeyboard(.interactively)
		.task { await fetch() }
		.refreshable { await fetch() }
	}
}

// MARK: - StacksView+Actions

private extension StacksView {
	func fetch() async {
		do {
			try await viewModel.getStacks()
		} catch {
			errorHandler(error)
		}
	}

	func setStackState(_ stack: Stack, started: Bool) {
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

// MARK: - Previews

#Preview("StacksView") {
	StacksView(selectedStack: .constant(nil))
		.environmentObject(PortainerStore.shared)
}

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
	@EnvironmentObject private var preferences: Preferences
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()
	@Binding var selectedStackName: String?

	@ViewBuilder
	private var placeholderView: some View {
		if viewModel.shouldShowEmptyPlaceholderView {
			if !viewModel.query.isEmpty {
				ContentUnavailableView.search(text: viewModel.query)
			} else {
				ContentUnavailableView("StacksView.NoContainersPlaceholder", systemImage: SFSymbol.xmark)
			}
		}
	}

	@ViewBuilder
	private var stacksList: some View {
		Form {
			if let stacks = viewModel.stacksFiltered {
				ForEach(stacks) { stackItem in
					let isLoading = viewModel.loadingStacks.contains(stackItem.id)
					let containers = portainerStore.containers.filter { $0.stack == stackItem.name }

					Group {
						if let stack = stackItem.stack {
							NavigationLink(value: StackDetailsView.NavigationItem(stackID: stackItem.id)) {
								StackCell(stackItem, containers: containers, isLoading: isLoading) {
									filterByStackName(stackItem.name)
								} toggleAction: {
									setStackState(stack, started: !stack.isOn)
								}
							}
						} else {
							StackCell(stackItem, containers: containers, isLoading: isLoading) {
								filterByStackName(stackItem.name)
							} toggleAction: {
								// don't do anything, as we can't do much with it
							}
						}
					}
					.transition(.opacity)
				}
			}
		}
		.formStyle(.grouped)
		.searchable(text: $viewModel.query)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		#if os(macOS)
		.frame(minWidth: Constants.Window.minWidth, minHeight: Constants.Window.minHeight)
		#endif
		.background {
			placeholderView
		}
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		.refreshable { await fetch().value }
	}

	var body: some View {
		NavigationStack {
			stacksList
				.toolbar {
					#if os(macOS)
					ToolbarItem(placement: .cancellationAction) {
						CloseButton {
							dismiss()
						}
					}
					#endif

					ToolbarItem(placement: .primaryAction) {
						Menu {
							Toggle("StacksView.IncludeLimitedStacks", isOn: $preferences.svIncludeLimitedStacks)
								.onChange(of: preferences.svIncludeLimitedStacks) {
									Haptics.generateIfEnabled(.selectionChanged)
									fetch()
								}
						} label: {
							Label("Generic.More", systemImage: SFSymbol.moreCircle)
						}
					}

					ToolbarItem(placement: .status) {
						DelayedView(isVisible: viewModel.viewState.showAdditionalLoadingView) {
							ProgressView()
						}
						.transition(.opacity)
					}
				}
				.navigationTitle("StacksView.Title")
				.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
					StackDetailsView(navigationItem: navigationItem, selectedStackName: $selectedStackName)
						.environment(viewModel)
				}
		}
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.stacks)
		.scrollDismissesKeyboard(.interactively)
		.task { await fetch().value }
	}
}

// MARK: - StacksView+Actions

private extension StacksView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.getStacks().value
			} catch {
				errorHandler(error)
			}
		}
	}

	func filterByStackName(_ stackName: String?) {
		selectedStackName = stackName
		dismiss()
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
	StacksView(selectedStackName: .constant(nil))
		.environmentObject(PortainerStore.shared)
}

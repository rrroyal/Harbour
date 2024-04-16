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
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()

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
		List {
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
					.tag(stackItem.id)
				}
			}
		}
		.listStyle(.insetGrouped)
		.scrollDismissesKeyboard(.interactively)
		.scrollPosition(id: $viewModel.scrollPosition)
		.searchable(text: $viewModel.query)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background {
			placeholderView
		}
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		.refreshable { await fetch().value }
	}

	@ViewBuilder
	private var content: some View {
		stacksList
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button {
						Haptics.generateIfEnabled(.sheetPresentation)
						viewModel.isCreateStackSheetPresented = true
					} label: {
						Label("StacksView.CreateStack", systemImage: SFSymbol.plus)
					}
				}

				ToolbarItem(placement: .automatic) {
					Menu {
						Toggle(isOn: $preferences.svIncludeLimitedStacks) {
							Label(
								"StacksView.Menu.IncludeLimitedStacks",
								systemImage: "square.stack.3d.up.trianglebadge.exclamationmark"
							)
						}
						.onChange(of: preferences.svIncludeLimitedStacks) {
							Haptics.generateIfEnabled(.selectionChanged)
							fetch()
						}

						Divider()

						Button {
							Haptics.generateIfEnabled(.sheetPresentation)
							sceneDelegate.isSettingsSheetPresented = true
						} label: {
							Label("SettingsView.Title", systemImage: SFSymbol.settings)
						}
						.keyboardShortcut(",", modifiers: .command)
					} label: {
						Label("Generic.More", systemImage: SFSymbol.moreCircle)
							.labelStyle(.iconOnly)
					}
					.labelStyle(.titleAndIcon)
				}

				ToolbarItem(placement: .status) {
					DelayedView(isVisible: viewModel.viewState.showAdditionalLoadingView) {
						ProgressView()
					}
					.transition(.opacity)
				}
			}
			.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
				StackDetailsView(navigationItem: navigationItem)
					.equatable()
					.tag(navigationItem.id)
					.environment(viewModel)
					.environment(sceneDelegate)
			}
			.navigationTitle("StacksView.Title")
	}

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate
		NavigationWrapped(navigationPath: $sceneDelegate.navigationPathStacks) {
			content
		} placeholderContent: {
			Text("StacksView.NoStackSelectedPlaceholder")
				.foregroundStyle(.tertiary)
		}
		.focusable()
		.focusEffectDisabled()
		.sheet(isPresented: $viewModel.isCreateStackSheetPresented) {
			NavigationStack {
				CreateStackView(onStackFileSelection: onStackFileSelection)
					.sheetHeader("CreateStackView.Title")
			}
			.presentationDetents([.medium, .large], selection: $viewModel.activeCreateStackSheetDetent)
			.presentationDragIndicator(.hidden)
			.presentationContentInteraction(.resizes)
		}
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.stacks)
		.task { await fetch().value }
	}
}

// MARK: - StacksView+Actions

private extension StacksView {
	@discardableResult
	func fetch(includingContainers: Bool? = nil) -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.getStacks(includingContainers: includingContainers).value
			} catch {
				errorHandler(error)
			}
		}
	}

	@MainActor
	func filterByStackName(_ stackName: String?) {
		Haptics.generateIfEnabled(.light)
		sceneDelegate.navigate(to: .containers)
		sceneDelegate.selectedStackName = stackName
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

	func onStackFileSelection(_ stackFileContents: String?) {
		if stackFileContents != nil {
			viewModel.activeCreateStackSheetDetent = .large
		}
	}

	func onStackCreation(_ stack: Stack) {
		fetch(includingContainers: true)
		viewModel.scrollPosition = stack.id.description
//		viewModel.navigationPath.removeLast(viewModel.navigationPath.count)
//		viewModel.navigationPath.append(StackDetailsView.NavigationItem(stack: stack))
	}
}

// MARK: - Previews

#Preview("StacksView") {
	StacksView()
		.withEnvironment(appState: .shared)
		.environment(SceneDelegate())
}

//
//  StacksView.swift
//  Harbour
//
//  Created by royal on 31/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import CoreSpotlight
import PortainerKit
import SwiftUI

// MARK: - StacksView

struct StacksView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel = ViewModel()
	@FocusState private var isFocused: Bool

	@ViewBuilder
	private var backgroundPlaceholder: some View {
		Group {
			if !portainerStore.isSetup {
				ContentUnavailableView(
					"Generic.NotSetup.Title",
					systemImage: SFSymbol.network,
					description: Text("Generic.NotSetup.Description")
				)
				.symbolVariant(.slash)
			} else if viewModel.stacks.isEmpty {
				if viewModel.viewState.isLoading {
					ProgressView()
				} else if !viewModel.searchText.isEmpty {
					ContentUnavailableView.search(text: viewModel.searchText)
				} else {
					ContentUnavailableView("StacksView.NoStacksPlaceholder", systemImage: SFSymbol.stack)
						.symbolVariant(.slash)
				}
			}
		}
	}

	@ToolbarContentBuilder
	private var toolbarContent: some ToolbarContent {
		var createStackToolbarItemPlacement: ToolbarItemPlacement {
			#if os(iOS)
			.navigation
			#elseif os(macOS)
			.primaryAction
			#endif
		}
		ToolbarItem(placement: createStackToolbarItemPlacement) {
			Button {
				Haptics.generateIfEnabled(.sheetPresentation)
				sceneDelegate.editedStack = nil
				sceneDelegate.isCreateStackSheetPresented = true
			} label: {
				Label("StacksView.CreateStack", systemImage: SFSymbol.plus)
			}
			.disabled(!portainerStore.isSetup)
		}

		ToolbarItem(placement: .automatic) {
			Menu {
				Toggle(isOn: $preferences.svFilterByActiveEndpoint) {
					Label(
						"StacksView.Menu.ActiveEndpointOnly",
						systemImage: "tag"
					)
				}
				.onChange(of: preferences.svFilterByActiveEndpoint) {
					Haptics.generateIfEnabled(.selectionChanged)
				}

				Toggle(isOn: $preferences.svIncludeLimitedStacks) {
					Label(
						"StacksView.Menu.IncludeLimitedStacks",
						systemImage: "square.stack.3d.up.trianglebadge.exclamationmark"
					)
				}
				.onChange(of: preferences.svIncludeLimitedStacks) {
					Haptics.generateIfEnabled(.selectionChanged)
					if preferences.svIncludeLimitedStacks {
						fetch()
					}
				}

				#if os(iOS)
				Divider()

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					sceneDelegate.isSettingsSheetPresented = true
				} label: {
					Label("SettingsView.Title", systemImage: SFSymbol.settings)
				}
				.keyboardShortcut(",", modifiers: .command)
				#endif
			} label: {
				Label("Generic.More", systemImage: SFSymbol.moreCircle)
					.labelStyle(.iconOnly)
			}
			.labelStyle(.titleAndIcon)
		}

//		ToolbarItem(placement: .status) {
//			DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//				ProgressView()
//			}
//		}
	}

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate

		StacksList(
			stacks: viewModel.stacks,
			filterByStackNameAction: filterByStackName,
			setStackStateAction: setStackState
		)
		.scrollPosition(id: $viewModel.scrollPosition)
		.searchable(text: $viewModel.searchText, isPresented: $viewModel.isSearchActive)
		.background {
			if viewModel.isBackgroundPlaceholderVisible {
				backgroundPlaceholder
			}
		}
		#if os(iOS)
		.background(
			viewState: viewModel.viewState,
			isViewStateBackgroundVisible: viewModel.stacks.isEmpty,
			backgroundVisiblity: .hidden,
			backgroundColor: .groupedBackground
		)
		#elseif os(macOS)
		.background(
			viewState: viewModel.viewState,
			isViewStateBackgroundVisible: viewModel.stacks.isEmpty,
			backgroundVisiblity: .hidden,
			backgroundColor: .clear
		)
		#endif
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await fetch().value
		}
		.toolbar {
			toolbarContent
		}
		.focusable()
		.focused($isFocused)
		.focusEffectDisabled()
		.confirmationDialog(
			"Generic.AreYouSure?",
			isPresented: sceneDelegate.isRemoveStackAlertPresented,
			titleVisibility: .visible,
			presenting: sceneDelegate.stackToRemove
		) { stack in
			Button("Generic.Remove", role: .destructive) {
				Haptics.generateIfEnabled(.heavy)
				removeStack(stack)
			}
		} message: { stack in
			Text("StacksView.RemoveStackAlert.Message StackName:\(stack.name)")
		}
		.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
			StackDetailsView(navigationItem: navigationItem)
				.equatable()
				.tag(navigationItem.id)
		}
		.navigationTitle("StacksView.Title")
		.environment(viewModel)
		.animation(.smooth, value: viewModel.viewState)
//		.animation(.smooth, value: viewModel.stacks)
		.animation(.smooth, value: viewModel.isStatusProgressViewVisible)
		.onKeyPress(action: onKeyPress)
		.onContinueUserActivity(CSQueryContinuationActionType) { userActivity in
//			guard sceneDelegate.activeTab == .stacks else { return }
			viewModel.handleSpotlightSearchContinuation(userActivity)
		}
		.task {
			if portainerStore.stacksTask?.isCancelled ?? true {
				await fetch().value
			}
		}
	}
}

// MARK: - StacksView+StacksList

private extension StacksView {
	struct StacksList: View {
		@Environment(StacksView.ViewModel.self) private var viewModel
		@EnvironmentObject private var portainerStore: PortainerStore
		var stacks: [StacksView.StackItem]
		var filterByStackNameAction: (String) -> Void
		var setStackStateAction: (Stack, Bool) -> Void

		var body: some View {
			List {
				ForEach(stacks) { stackItem in
					let containers = portainerStore.containers.filter { $0.stack == stackItem.name }

					Group {
						if let stack = stackItem.stack {
							NavigationLink(value: StackDetailsView.NavigationItem(stackID: stackItem.id, stackName: stackItem.name)) {
								StackCell(
									stackItem,
									containers: containers,
									filterAction: { filterByStackNameAction(stackItem.name) },
									setStackStateAction: { setStackStateAction(stack, $0) }
								)
							}
						} else {
							StackCell(
								stackItem,
								containers: containers,
								filterAction: { filterByStackNameAction(stackItem.name) },
								setStackStateAction: { _ in }
							)
						}
					}
					.tag(stackItem.id)
					#if os(macOS)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					#endif
				}
			}
			#if os(iOS)
			.listStyle(.insetGrouped)
			#elseif os(macOS)
			.listStyle(.sidebar)
			#endif
			.animation(.smooth, value: stacks)
		}
	}
}

// MARK: - StacksView+Actions

private extension StacksView {
	@discardableResult
	func fetch(includingContainers: Bool? = nil) -> Task<Void, Never> {
		Task {
			guard portainerStore.isSetup else { return }

			do {
				try await viewModel.fetch(includingContainers: includingContainers).value
			} catch {
				errorHandler(error)
			}
		}
	}

	func filterByStackName(_ stackName: String?) {
		sceneDelegate.navigate(to: .containers)
		sceneDelegate.selectedStackName = stackName
	}

	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				presentIndicator(.stackStartOrStop(stack.name, started: started, state: .loading))
				try await viewModel.setStackState(stackID: stack.id, started: started)
				presentIndicator(.stackStartOrStop(stack.name, started: started, state: .success))
			} catch {
				presentIndicator(.stackStartOrStop(stack.name, started: started, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func removeStack(_ stack: Stack) {
		Task {
			do {
				presentIndicator(.stackRemove(stack.name, stack.id, state: .loading))

				try await viewModel.removeStack(stackID: stack.id)
				presentIndicator(.stackRemove(stack.name, stack.id, state: .success))

				sceneDelegate.navigate(to: .stacks)
			} catch {
				presentIndicator(.stackRemove(stack.name, stack.id, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func onKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
		switch keyPress.key {
			// ⌘F
		case "f" where keyPress.modifiers.contains(.command):
			viewModel.isSearchActive = true
			return .handled
		case "n" where keyPress.modifiers.contains(.command):
			sceneDelegate.isCreateStackSheetPresented = true
			return .handled
		default:
			return .ignored
		}
	}
}

// MARK: - Previews

#Preview("StacksView") {
	StacksView()
		.withEnvironment(appState: .shared)
		.environment(SceneDelegate())
}

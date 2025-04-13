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
	@Environment(AppState.self) private var appState
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel = ViewModel()
	@FocusState private var isFocused: Bool

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
				Toggle(isOn: $preferences.svFilterByActiveEndpoint.withHaptics(.selectionChanged)) {
					Label {
						Text("StacksView.Menu.ActiveEndpointOnly")
					} icon: {
						Image(systemName: SFSymbol.endpoint)
					}

					if let selectedEndpoint = portainerStore.selectedEndpoint {
						Text(selectedEndpoint.name ?? selectedEndpoint.id.description)
					}
				}
				.onChange(of: preferences.svFilterByActiveEndpoint) {
					fetch()
				}

				Toggle(isOn: $preferences.svIncludeLimitedStacks.withHaptics(.selectionChanged)) {
					Label(
						"StacksView.Menu.IncludeLimitedStacks",
						systemImage: "square.stack.3d.up.trianglebadge.exclamationmark"
					)
				}
				.onChange(of: preferences.svIncludeLimitedStacks) {
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

	@ViewBuilder @MainActor
	private var backgroundPlaceholder: some View {
		let isLoading = viewModel.viewState.isLoading ||
			!(portainerStore.stacksTask?.isCancelled ?? true) ||
			!(appState.portainerServerSwitchTask?.isCancelled ?? true)

		if isLoading {
			ProgressView()
		} else if case .failure = viewModel.viewState {
			viewModel.viewState.backgroundView
		} else if !portainerStore.isSetup {
			ContentUnavailableView(
				"Portainer.NotSetup.Title",
				systemImage: SFSymbol.network,
				description: Text("Portainer.NotSetup.Description")
			)
			.symbolVariant(.slash)
		} else if !viewModel.searchText.isEmpty {
			ContentUnavailableView.search(text: viewModel.searchText)
		} else {
			ContentUnavailableView("StacksView.NoStacksPlaceholder", systemImage: SFSymbol.stack)
				.symbolVariant(.slash)
		}
	}

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate
		let stacks = viewModel.stacks

		StacksList(
			stacks: viewModel.stacks,
			filterByStackNameAction: filterByStackName,
			setStackStateAction: setStackState
		)
		.scrollContentBackground(.hidden)
		.scrollPosition(id: $viewModel.scrollPosition)
		.background {
			if stacks.isEmpty {
				backgroundPlaceholder
			}
		}
		#if os(iOS)
		.background(.groupedBackground, ignoresSafeAreaEdges: .all)
		#elseif os(macOS)
		.background(.clear, ignoresSafeAreaEdges: .all)
		#endif
		.searchable(text: $viewModel.searchText, isPresented: $viewModel.isSearchActive)
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
			"Generic.AreYouSure",
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
		.navigationTitle("StacksView.Title")
		.environment(viewModel)
		.animation(.default, value: viewModel.viewState)
//		.animation(.default, value: viewModel.stacks)
		.animation(.default, value: viewModel.isStatusProgressViewVisible)
		.onChange(of: sceneDelegate.selectedStackNameForStacksView) { _, stackName in
			viewModel.searchText = stackName ?? ""
		}
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
								setStackStateAction: nil
							)
						}
					}
					#if os(macOS)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					.listRowSeparator(.hidden)
					#endif
				}
			}
			#if os(iOS)
			.listStyle(.insetGrouped)
			#elseif os(macOS)
			.listStyle(.inset)
			#endif
			.animation(.default, value: stacks)
		}
	}
}

// MARK: - StacksView+Actions

private extension StacksView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			guard portainerStore.isSetup else { return }

			do {
				try await viewModel.fetch().value
			} catch {
				errorHandler(error)
			}
		}
	}

	func filterByStackName(_ stackName: String?) {
		sceneDelegate.navigate(to: .containers)
		sceneDelegate.selectedStackNameForContainersView = stackName
	}

	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				presentIndicator(.stackStartOrStop(stackName: stack.name, started: started, state: .loading))
				try await viewModel.setStackState(stackID: stack.id, started: started)
				presentIndicator(.stackStartOrStop(stackName: stack.name, started: started, state: .success))
			} catch {
				presentIndicator(.stackStartOrStop(stackName: stack.name, started: started, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func removeStack(_ stack: Stack) {
		Task {
			do {
				presentIndicator(.stackRemove(stackName: stack.name, state: .loading))

				try await viewModel.removeStack(stackID: stack.id)
				presentIndicator(.stackRemove(stackName: stack.name, state: .success))

				sceneDelegate.navigate(to: .stacks)
			} catch {
				presentIndicator(.stackRemove(stackName: stack.name, state: .failure(error)))
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
		.withEnvironment()
		.environment(SceneDelegate())
}

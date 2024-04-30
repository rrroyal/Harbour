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
				} else if !viewModel.query.isEmpty {
					ContentUnavailableView.search(text: viewModel.query)
				} else {
					ContentUnavailableView("StacksView.NoStacksPlaceholder", systemImage: SFSymbol.stack)
						.symbolVariant(.slash)
				}
			}
		}
	}

	var body: some View {
		List {
			ForEach(viewModel.stacks) { stackItem in
				let isLoading = portainerStore.loadingStacks.contains(Stack.ID(stackItem.id) ?? -1)
				let containers = portainerStore.containers.filter { $0.stack == stackItem.name }

				Group {
					if let stack = stackItem.stack {
						NavigationLink(value: StackDetailsView.NavigationItem(stackID: stackItem.id, stackName: stackItem.name)) {
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
		.scrollPosition(id: $viewModel.scrollPosition)
		.searchable(text: $viewModel.query, isPresented: $viewModel.isSearchActive)
		.background {
			if viewModel.isBackgroundPlaceholderVisible {
				backgroundPlaceholder
			}
		}
		#if os(iOS)
		.background(viewState: viewModel.viewState, backgroundVisiblity: .hidden, backgroundColor: .groupedBackground)
		#elseif os(macOS)
		.background(viewState: viewModel.viewState, backgroundVisiblity: .hidden, backgroundColor: .clear)
		#endif
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await fetch().value
		}
		.toolbar {
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
					viewModel.isCreateStackSheetPresented = true
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

//			ToolbarItem(placement: .status) {
//				DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//					ProgressView()
//				}
//				.transition(.opacity)
//			}
		}
		.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
			StackDetailsView(navigationItem: navigationItem)
				.equatable()
				.tag(navigationItem.id)
		}
		.navigationTitle("StacksView.Title")
		.sheet(isPresented: $viewModel.isCreateStackSheetPresented) {
			NavigationStack {
				CreateStackView(onStackFileSelection: onStackFileSelection)
					#if os(iOS)
					.navigationBarTitleDisplayMode(.inline)
					#endif
					.addingCloseButton()
			}
			.presentationDetents([.medium, .large], selection: $viewModel.activeCreateStackSheetDetent)
			.presentationDragIndicator(.hidden)
			.presentationContentInteraction(.resizes)
			#if os(macOS)
			.sheetMinimumFrame(width: 380, height: 400)
			#endif
		}
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.stacks)
		.animation(.easeInOut, value: viewModel.isStatusProgressViewVisible)
//		.animation(.easeInOut, value: viewModel.selectedStackID)
		.focusable()
		.focused($isFocused)
		.focusEffectDisabled()
		.onKeyPress(action: onKeyPress)
		.task {
			if portainerStore.stacksTask?.isCancelled ?? true {
				await fetch().value
			}
		}
		.onAppear {
			isFocused = true
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
				try await viewModel.getStacks(includingContainers: includingContainers).value
			} catch {
				errorHandler(error)
			}
		}
	}

	func filterByStackName(_ stackName: String?) {
		Haptics.generateIfEnabled(.light)
		sceneDelegate.navigate(to: .containers)
		sceneDelegate.selectedStackName = stackName
	}

	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				Haptics.generateIfEnabled(.light)
				try await viewModel.setStackState(stack.id, started: started)
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

	func onKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
		switch keyPress.key {
			// ⌘F
		case "f" where keyPress.modifiers.contains(.command):
			viewModel.isSearchActive = true
			return .handled
		case "n" where keyPress.modifiers.contains(.command):
			viewModel.isCreateStackSheetPresented = true
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

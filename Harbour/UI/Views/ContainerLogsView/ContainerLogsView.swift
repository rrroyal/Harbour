//
//  ContainerLogsView.swift
//  Harbour
//
//  Created by royal on 21/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - ContainerLogsView

struct ContainerLogsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences
	@Environment(\.errorHandler) private var errorHandler
//	@Environment(\.presentIndicator) private var presentIndicator

	@State private var viewModel: ViewModel
	@FocusState private var isSearchFocused: Bool

	var containerID: Container.ID

	init(containerID: Container.ID) {
		self.containerID = containerID

		let viewModel = ViewModel(containerID: containerID)
		self.viewModel = viewModel
	}

	var body: some View {
		ScrollViewReader { scrollProxy in
			Group {
				if let logs = viewModel.logs {
					ScrollView {
						if preferences.clSeparateLines {
							SeparatedView(
								logs: logs,
								scrollProxy: scrollProxy,
								includeTimestamps: preferences.clIncludeTimestamps,
								searchText: viewModel.isSearchVisible ? viewModel.searchText : ""
							)
						} else {
							TextView(
								logs: logs,
								scrollProxy: scrollProxy,
								searchText: viewModel.isSearchVisible ? viewModel.searchText : ""
							)
						}
					}
					.defaultScrollAnchor(.bottom, for: .initialOffset)
					.font(.caption.monospaced())
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					ToolbarMenu(
						viewModel: viewModel,
						focusTextfieldAction: { isSearchFocused = true },
						scrollAction: { scrollLogs(anchor: $0, scrollProxy: scrollProxy) }
					)
				}

				ToolbarItem(placement: .status) {
					DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
						ProgressView()
					}
				}
			}
//			#if os(iOS)
			.modifier(
				WithSearchBarModifier(
					searchText: $viewModel.searchText,
					isSearchBarVisible: $viewModel.isSearchVisible,
					isSearchFocused: _isSearchFocused,
					occurenceCount: viewModel.searchOccurences
				) {
					Menu {
						Toggle(isOn: $viewModel.isSearchFilteringLines.withHaptics(.light)) {
							Label("ContainerLogsView.Search.FilterLines", systemImage: "line.3.horizontal.decrease")
						}
						.labelStyle(.titleAndIcon)
					} label: {
						Image(systemName: "text.magnifyingglass")
							.fontWeight(.semibold)
							.padding(4)
					}
					.menuStyle(.button)
					.buttonStyle(.plain)
					.foregroundStyle(.tertiary)
					.padding(-4)
				} doneAction: {
					viewModel.isSearchVisible = false
					isSearchFocused = false
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						viewModel.searchText = ""
					}
				}
			)
//			#elseif os(macOS)
//			.searchable(text: $viewModel.searchText, isPresented: $viewModel.isSearchVisible)
//			#endif
		}
		.background {
			if !viewModel.isLoading && !viewModel.viewState.isError && viewModel.logs?.isEmpty ?? true {
				if !viewModel.searchText.isReallyEmpty {
					ContentUnavailableView.search(text: viewModel.searchText)
				} else {
					ContentUnavailableView("ContainerLogsView.NoLogs", systemImage: SFSymbol.xmark)
				}
			}
		}
		.viewStateBackground(viewModel.viewState, backgroundColor: .groupedBackground)
		.animation(.default, value: viewModel.viewState)
		.animation(.default, value: viewModel.logs)
		.animation(.default, value: viewModel.isSearchVisible)
		.animation(.default, value: viewModel.isSearchFilteringLines)
		.animation(.default, value: preferences.clSeparateLines)
		.animation(.default, value: preferences.clIncludeTimestamps)
		.navigationTitle("ContainerLogsView.Title")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await fetch().value
		}
		.onKeyPress(action: onKeyPress)
		.task {
			await fetch().value
		}
		.onChange(of: containerID) { _, newID in
			viewModel.containerID = newID
			fetch()
		}
		.onChange(of: viewModel.lineCount) {
			fetch()
		}
		.onChange(of: preferences.clIncludeTimestamps) {
			fetch()
		}
	}
}

// MARK: - ContainerLogsView+Actions

private extension ContainerLogsView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.getLogs().value
			} catch {
				errorHandler(error)
			}
		}
	}

	func scrollLogs(anchor: UnitPoint, scrollProxy: ScrollViewProxy) {
		withAnimation {
			scrollProxy.scrollTo(ViewID.logsLabel, anchor: anchor)
		}
	}

	func onKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
		switch keyPress.key {
			// ⌘F
		case "f" where keyPress.modifiers.contains(.command):
			viewModel.isSearchVisible = true
			isSearchFocused = true
			return .handled
		default:
			return .ignored
		}
	}
}

// MARK: - ContainerLogsView+ViewID

extension ContainerLogsView {
	enum ViewID {
		case logsLabel
	}
}

// MARK: - ContainerLogsView+ToolbarMenu

private extension ContainerLogsView {
	struct ToolbarMenu: View {
		@EnvironmentObject private var preferences: Preferences
		@Environment(\.errorHandler) private var errorHandler
		@Environment(\.presentIndicator) private var presentIndicator
		var viewModel: ViewModel
		var focusTextfieldAction: () -> Void
		var scrollAction: (UnitPoint) -> Void

		@ViewBuilder
		private var refreshButton: some View {
			Button {
				Haptics.generateIfEnabled(.buttonPress)
				Task {
					do {
						try await viewModel.getLogs().value
					} catch {
						errorHandler(error)
					}
				}
			} label: {
				Label("Generic.Refresh", systemImage: SFSymbol.reload)
			}
			.keyboardShortcut("r", modifiers: .command)
		}

		@ViewBuilder
		private var searchButton: some View {
			Button {
				Haptics.generateIfEnabled(.buttonPress)
				if !viewModel.isSearchVisible {
					viewModel.searchText = ""
				}
				viewModel.isSearchVisible = true
				focusTextfieldAction()
			} label: {
				Label("Generic.Search", systemImage: SFSymbol.search)
			}
			.keyboardShortcut("f", modifiers: .command)
		}

		@ViewBuilder
		private var scrollButtons: some View {
			Button {
				Haptics.generateIfEnabled(.rigid)
				scrollAction(.top)
			} label: {
				Label("ContainerLogsView.Menu.ScrollToTop", systemImage: SFSymbol.arrowUpLine)
			}
			.keyboardShortcut(.upArrow, modifiers: .command)

			Button {
				Haptics.generateIfEnabled(.rigid)
				scrollAction(.bottom)
			} label: {
				Label("ContainerLogsView.Menu.ScrollToBottom", systemImage: SFSymbol.arrowDownLine)
			}
			.keyboardShortcut(.downArrow, modifiers: .command)
		}

		@ViewBuilder
		private var separateLinesButton: some View {
			Toggle(isOn: $preferences.clSeparateLines.withHaptics(.selectionChanged)) {
				Label("ContainerLogsView.Menu.SeparateLines", systemImage: "rectangle.split.1x2")
			}
		}

		@ViewBuilder
		private var includeTimestampsButton: some View {
			Toggle(isOn: $preferences.clIncludeTimestamps.withHaptics(.selectionChanged)) {
				Label("ContainerLogsView.Menu.IncludeTimestamps", systemImage: "clock")
			}
		}

		@ViewBuilder
		private var logLinesMenu: some View {
			@Bindable var viewModel = viewModel

			let lineCounts: [Int] = [
				100,
				250,
				500,
				1_000
			]

			Picker(selection: $viewModel.lineCount.withHaptics(.selectionChanged)) {
				ForEach(lineCounts, id: \.self) { amount in
					Text(amount.formatted())
						.tag(amount)
				}
			} label: {
				Label("ContainerLogsView.Menu.LineCount", systemImage: SFSymbol.logs)
			}
			.pickerStyle(.menu)
		}

		@ViewBuilder
		private var copyButton: some View {
			if let shareableContent = viewModel.viewState.value {
				CopyButton(content: shareableContent)
			}
		}

		@ViewBuilder
		private var shareButton: some View {
			if let shareableContent = viewModel.viewState.value {
				ShareLink(item: shareableContent, preview: .init(.init(verbatim: shareableContent)))
					.keyboardShortcut("u", modifiers: .command)
			}
		}

		var body: some View {
			Menu {
				switch viewModel.viewState {
				case .loading:
					Text("Generic.Loading")
				case .success:
					refreshButton
//					#if os(iOS)
					searchButton
//					#endif
					Divider()
					scrollButtons
					Divider()
					separateLinesButton
					includeTimestampsButton
					logLinesMenu
					Divider()
					copyButton
					shareButton
				default:
					refreshButton
				}
			} label: {
				Label("Generic.More", systemImage: SFSymbol.moreCircle)
					.labelStyle(.iconOnly)
			}
			.labelStyle(.titleAndIcon)
		}
	}
}

// MARK: - Previews

#Preview(traits: .modifier(PortainerStorePreviewModifier())) {
	ContainerLogsView(containerID: "")
		.withEnvironment()
}

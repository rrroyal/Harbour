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
								includeTimestamps: preferences.clIncludeTimestamps
							)
						} else {
							TextView(logs: logs, scrollProxy: scrollProxy)
						}
					}
					.defaultScrollAnchor(.bottom, for: .initialOffset)
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					ToolbarMenu(
						viewState: viewModel.viewState,
						lineCount: $viewModel.lineCount,
						shareableContent: viewModel.viewState.value,
						scrollAction: { scrollLogs(anchor: $0, scrollProxy: scrollProxy) },
						refreshAction: { fetch() }
					)
				}

				ToolbarItem(placement: .status) {
					DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
						ProgressView()
					}
				}
			}
		}
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		.background {
			if !viewModel.isLoading && viewModel.logs?.isEmpty ?? true {
				ContentUnavailableView("ContainerLogsView.NoLogs", systemImage: SFSymbol.xmark)
			}
		}
		.animation(.default, value: viewModel.viewState)
		.animation(.default, value: viewModel.logs)
		.animation(.default, value: preferences.clSeparateLines)
		.animation(.default, value: preferences.clIncludeTimestamps)
		.navigationTitle("ContainerLogsView.Title")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await fetch().value
		}
//		.searchable(text: $searchText)
		.task {
			await fetch().value
		}
		.onChange(of: containerID) { _, newID in
			viewModel.containerID = newID
		}
		.onChange(of: viewModel.lineCount) {
			fetch()
		}
		.onChange(of: preferences.clIncludeTimestamps) {
			fetch()
		}
	}
}

// MARK: - ContainerLogsView+Static

extension ContainerLogsView {
	static let normalFont: Font = .caption.monospaced()
}

// MARK: - ContainerLogsView+Actions

private extension ContainerLogsView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.getLogs(includeTimestamps: preferences.clIncludeTimestamps).value
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
		@Environment(\.presentIndicator) private var presentIndicator
		let viewState: ViewModel._ViewState
		@Binding var lineCount: Int
		let shareableContent: String?
		let scrollAction: (UnitPoint) -> Void
		let refreshAction: () -> Void

		@ViewBuilder
		private var refreshButton: some View {
			Button {
				Haptics.generateIfEnabled(.buttonPress)
				refreshAction()
			} label: {
				Label("Generic.Refresh", systemImage: SFSymbol.reload)
			}
		}

		@ViewBuilder
		private var scrollButtons: some View {
			Button {
				Haptics.generateIfEnabled(.rigid)
				scrollAction(.top)
			} label: {
				Label("ContainerLogsView.Menu.ScrollToTop", systemImage: SFSymbol.arrowUpLine)
			}

			Button {
				Haptics.generateIfEnabled(.rigid)
				scrollAction(.bottom)
			} label: {
				Label("ContainerLogsView.Menu.ScrollToBottom", systemImage: SFSymbol.arrowDownLine)
			}
		}

		@ViewBuilder
		private var separateLinesButton: some View {
			Toggle(isOn: $preferences.clSeparateLines) {
				Label("ContainerLogsView.Menu.SeparateLines", systemImage: "rectangle.split.1x2")
			}
			.onChange(of: preferences.clSeparateLines) {
				Haptics.generateIfEnabled(.selectionChanged)
			}
		}

		@ViewBuilder
		private var includeTimestampsButton: some View {
			Toggle(isOn: $preferences.clIncludeTimestamps) {
				Label("ContainerLogsView.Menu.IncludeTimestamps", systemImage: "clock")
			}
			.onChange(of: preferences.clIncludeTimestamps) {
				Haptics.generateIfEnabled(.selectionChanged)
			}
		}

		@ViewBuilder
		private var logLinesMenu: some View {
			let lineCounts: [Int] = [
				100,
				250,
				500,
				1_000
			]
			Picker(selection: $lineCount) {
				ForEach(lineCounts, id: \.self) { amount in
					Text(amount.formatted())
						.tag(amount)
				}
			} label: {
				Label("ContainerLogsView.Menu.LineCount", systemImage: SFSymbol.logs)
			}
			.pickerStyle(.menu)
			.onChange(of: lineCount) {
				Haptics.generateIfEnabled(.selectionChanged)
			}
		}

		@ViewBuilder
		private var copyButton: some View {
			CopyButton(content: shareableContent)
		}

		@ViewBuilder
		private var shareButton: some View {
			if let shareableContent {
				ShareLink(item: shareableContent, preview: .init(.init(verbatim: shareableContent)))
			}
		}

		var body: some View {
			Menu {
				switch viewState {
				case .loading:
					Text("Generic.Loading")
				case .success:
					refreshButton
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

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
			ScrollView {
				LazyVStack {
					Text(viewModel.logs ?? "")
						.font(.caption)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
						// .textRenderer(HighlightedTextRenderer(highlightedText: ""))
						#if os(iOS)
						.padding(.horizontal, 10)
						#elseif os(macOS)
						.padding(.horizontal)
						#endif
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
						.id(ViewID.logsLabel)
				}
			}
			.defaultScrollAnchor(.bottom, for: .initialOffset)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					ToolbarMenu(
						viewState: viewModel.viewState,
						lineCount: $viewModel.lineCount,
						includeTimestamps: $viewModel.includeTimestamps,
						shareableContent: viewModel.viewState.value,
						scrollAction: { scrollLogs(anchor: $0, scrollProxy: scrollProxy) },
						refreshAction: { fetch() }
					)
				}

//				ToolbarItem(placement: .status) {
//					DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//						ProgressView()
//					}
//				}
			}
		}
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		.animation(.default, value: viewModel.viewState)
		.animation(.default, value: viewModel.logs)
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
		.onChange(of: viewModel.includeTimestamps) {
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
}

// MARK: - ContainerLogsView+ViewID

private extension ContainerLogsView {
	enum ViewID {
		case logsLabel
	}
}

// MARK: - ContainerLogsView+ToolbarMenu

private extension ContainerLogsView {
	struct ToolbarMenu: View {
		@Environment(\.presentIndicator) private var presentIndicator
		let viewState: ViewModel._ViewState
		@Binding var lineCount: Int
		@Binding var includeTimestamps: Bool
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
		private var includeTimestampsButton: some View {
			Toggle(isOn: $includeTimestamps) {
				Label("ContainerLogsView.Menu.IncludeTimestamps", systemImage: "clock")
			}
			.onChange(of: includeTimestamps) {
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

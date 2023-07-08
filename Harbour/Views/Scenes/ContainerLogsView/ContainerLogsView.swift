//
//  ContainerLogsView.swift
//  Harbour
//
//  Created by royal on 21/01/2023.
//

import CommonHaptics
import SwiftUI

// MARK: - ContainerLogsView

struct ContainerLogsView: View {
	private typealias Localization = Localizable.ContainerLogsView

	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.showIndicator) private var showIndicator

	@StateObject private var viewModel: ViewModel

	let navigationItem: ContainerNavigationItem

	init(navigationItem: ContainerNavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(containerNavigationItem: navigationItem)
		self._viewModel = .init(wrappedValue: viewModel)
	}

	var body: some View {
		ScrollViewReader { scrollProxy in
			ScrollView {
				if let logsViewable = viewModel.logsViewable {
					LogsView(logs: logsViewable)
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					ToolbarMenu(viewState: viewModel.viewState,
								linesCount: $viewModel.linesCount,
								includeTimestamps: $viewModel.includeTimestamps,
								shareableContent: viewModel.logs,
								scrollAction: { scrollLogs(anchor: $0, scrollProxy: scrollProxy) },
								refreshAction: { viewModel.getLogs(errorHandler: errorHandler) })
				}
			}
		}
		.background(PlaceholderView(viewState: viewModel.viewState))
		.navigationTitle(Localization.title)
		.refreshable {
			await viewModel.getLogs(errorHandler: errorHandler).value
		}
//		.searchable(text: $searchQuery)
		.task(id: navigationItem.id) {
			await viewModel.getLogs(errorHandler: errorHandler).value
		}
		.onChange(of: viewModel.includeTimestamps) {
			viewModel.getLogs(errorHandler: errorHandler)
		}
	}
}

// MARK: - ContainerLogsView+Actions

private extension ContainerLogsView {
	func scrollLogs(anchor: UnitPoint, scrollProxy: ScrollViewProxy) {
		withAnimation {
			scrollProxy.scrollTo(LogsView.labelID, anchor: anchor)
		}
	}
}

// MARK: - ContainerLogsView+ToolbarMenu

private extension ContainerLogsView {
	struct ToolbarMenu: View {
		@Environment(\.showIndicator) private var showIndicator
		let viewState: ViewModel.ViewState
		@Binding var linesCount: Int
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
				Label(Localizable.Generic.refresh, systemImage: SFSymbol.reload)
			}
		}

		@ViewBuilder
		private var scrollButtons: some View {
			Button {
				Haptics.generateIfEnabled(.light)
				scrollAction(.top)
			} label: {
				Label(Localization.Menu.scrollToTop, systemImage: SFSymbol.scrollToTop)
			}

			Button {
				Haptics.generateIfEnabled(.light)
				scrollAction(.bottom)
			} label: {
				Label(Localization.Menu.scrollToBottom, systemImage: SFSymbol.scrollToBottom)
			}
		}

		@ViewBuilder
		private var includeTimestampsButton: some View {
			Button {
				Haptics.generateIfEnabled(.selectionChanged)
				includeTimestamps.toggle()
			} label: {
				Label(Localization.Menu.includeTimestamps, systemImage: includeTimestamps ? SFSymbol.checkmark : "")
			}
		}

		@ViewBuilder
		private var logLinesMenu: some View {
			let lineCounts: [Int] = [
				100,
				1_000,
				10_000,
				100_000
			]
			Menu(Localization.Menu.linesCount) {
				ForEach(lineCounts, id: \.self) { amount in
					let isSelected = linesCount == amount
					Button {
						Haptics.generateIfEnabled(.selectionChanged)
						linesCount = amount
					} label: {
						Label(amount.formatted(), systemImage: isSelected ? SFSymbol.checkmark : "")
					}
				}
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
					Text(Localizable.Generic.loading)
				case .hasLogs:
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
				Label(Localizable.Generic.more, systemImage: SFSymbol.moreCircle)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerLogsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
}

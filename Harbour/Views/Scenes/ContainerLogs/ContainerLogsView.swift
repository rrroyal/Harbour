//
//  ContainerLogsView.swift
//  Harbour
//
//  Created by royal on 21/01/2023.
//

import SwiftUI
import CommonHaptics

// MARK: - ContainerLogsView

struct ContainerLogsView: View {
	private typealias Localization = Localizable.ContainerLogs

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
								scrollAction: { scrollLogs(anchor: $0, scrollProxy: scrollProxy) },
								copyAction: { viewModel.copyLogs(showIndicatorAction: showIndicator) },
								refreshAction: { viewModel.getLogs(errorHandler: errorHandler) })
				}
			}
		}
		.background(PlaceholderView(viewState: viewModel.viewState))
		.navigationTitle(Localization.navigationTitle)
		.refreshable {
			await viewModel.getLogs(errorHandler: errorHandler).value
		}
//		.searchable(text: $searchQuery)
		.task(id: navigationItem.id) {
			await viewModel.getLogs(errorHandler: errorHandler).value
		}
		.onChange(of: viewModel.includeTimestamps) { _ in
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
		let scrollAction: (UnitPoint) -> Void
		let copyAction: () -> Void
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
				Label(Localization.Menu.includeTimestamps, systemImage: includeTimestamps ? SFSymbol.selected : "")
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
						Label(amount.formatted(), systemImage: isSelected ? SFSymbol.selected : "")
					}
				}
			}
		}

		@ViewBuilder
		private var copyButton: some View {
			Button {
				Haptics.generateIfEnabled(.selectionChanged)
				copyAction()
			} label: {
				Label(Localizable.Generic.copy, systemImage: SFSymbol.copy)
			}
		}

		var body: some View {
			Menu {
				switch viewState {
				case .loading:
					Text(Localizable.Generic.loading)
				case .hasLogs:
					scrollButtons
					Divider()
					includeTimestampsButton
					logLinesMenu
					Divider()
					refreshButton
					copyButton
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

struct ContainerLogsView_Previews: PreviewProvider {
	static var previews: some View {
		ContainerLogsView(navigationItem: .init(id: "", displayName: "Containy", endpointID: nil))
	}
}

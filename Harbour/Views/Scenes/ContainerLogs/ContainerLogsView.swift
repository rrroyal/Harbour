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
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler
	@Environment(\.showIndicatorAction) private var showIndicatorAction

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
								includeTimestamps: $viewModel.includeTimestamps,
								scrollAction: { scrollLogs(anchor: $0, scrollProxy: scrollProxy) },
								copyAction: { viewModel.copyLogs(showIndicatorAction: showIndicatorAction) },
								refreshAction: { viewModel.getLogs(errorHandler: sceneErrorHandler) })
				}
			}
		}
		.background(PlaceholderView(viewState: viewModel.viewState))
		.navigationTitle(Localization.navigationTitle)
		.refreshable {
			await viewModel.getLogs(errorHandler: sceneErrorHandler).value
		}
//		.searchable(text: $searchQuery)
		.task(id: navigationItem.id) {
			await viewModel.getLogs(errorHandler: sceneErrorHandler).value
		}
		.onChange(of: viewModel.includeTimestamps) { _ in
			viewModel.getLogs(errorHandler: sceneErrorHandler)
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
		@Environment(\.showIndicatorAction) private var showIndicatorAction
		let viewState: ViewModel.ViewState
		@Binding var includeTimestamps: Bool
		let scrollAction: (UnitPoint) -> Void
		let copyAction: () -> Void
		let refreshAction: () -> Void

		@ViewBuilder
		private var refreshButton: some View {
			Button(action: {
				Haptics.generateIfEnabled(.buttonPress)
				refreshAction()
			}) {
				Label(Localizable.Generic.refresh, systemImage: SFSymbol.reload)
			}
		}

		@ViewBuilder
		private var scrollButtons: some View {
			Button(action: {
				Haptics.generateIfEnabled(.light)
				scrollAction(.top)
			}) {
				Label(Localization.Menu.scrollToTop, systemImage: SFSymbol.scrollToTop)
			}

			Button(action: {
				Haptics.generateIfEnabled(.light)
				scrollAction(.bottom)
			}) {
				Label(Localization.Menu.scrollToBottom, systemImage: SFSymbol.scrollToBottom)
			}
		}

		@ViewBuilder
		private var includeTimestampsButton: some View {
			Button(action: {
				Haptics.generateIfEnabled(.selectionChanged)
				includeTimestamps.toggle()
			}) {
				Label(Localization.Menu.includeTimestamps, systemImage: includeTimestamps ? SFSymbol.selected : "")
			}
		}

		@ViewBuilder
		private var copyButton: some View {
			Button(action: {
				Haptics.generateIfEnabled(.selectionChanged)
				copyAction()
			}) {
				Label(Localizable.Generic.copy, systemImage: SFSymbol.copy)
			}
		}

		var body: some View {
			Menu(content: {
				switch viewState {
					case .loading:
						Text(Localizable.Generic.loading)
					case .hasLogs:
						scrollButtons
						Divider()
						includeTimestampsButton
						// TODO: Log lines amount menu
						Divider()
						refreshButton
						copyButton
					default:
						refreshButton
				}
			}) {
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

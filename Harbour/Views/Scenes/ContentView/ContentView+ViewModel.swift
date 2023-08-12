//
//  ContentView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import PortainerKit

// MARK: - ContentView+ViewModel

extension ContentView {
	@MainActor
	final class ViewModel: ObservableObject {
		private let portainerStore: PortainerStore
		private let preferences = Preferences.shared

		private var fetchTask: Task<Void, Error>?
		private var suggestedSearchTokensTask: Task<Void, Error>?

		@Published @MainActor private(set) var viewState: ViewState<[Container]?, Error> = .loading
		@Published @MainActor private(set) var suggestedSearchTokens: [SearchToken] = []

		@Published @MainActor var searchText = ""
		@Published @MainActor var searchTokens: [SearchToken] = []
		@Published @MainActor var isLandingSheetPresented = !Preferences.shared.landingDisplayed

		var containers: [Container]? {
			viewState.unwrappedValue??
				.filter { container in
					for token in searchTokens {
						let matches = token.matches(container: container)
						if !matches { return false }
					}

					return true
				}
				.filter(searchText)
		}

		var shouldShowEmptyPlaceholderView: Bool {
			!viewState.isLoading && containers?.isEmpty ?? true
		}

		var shouldUseColumns: Bool {
			#if os(iOS)
			guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
				return false
			}
			#endif
			return preferences.cvUseColumns
		}

		var navigationTitle: String {
			portainerStore.selectedEndpoint?.name ?? String(localized: "ContentView.NoEndpointSelected")
		}

		init() {
			let portainerStore = PortainerStore.shared
			self.portainerStore = portainerStore

			Task {
				self.viewState = .success(portainerStore.containers)
			}
		}

		@MainActor
		func refresh() async throws {
			fetchTask?.cancel()
			self.fetchTask = Task {
				do {
					viewState = viewState.reloadingUnwrapped
					let task = portainerStore.refresh()
					let (_, containers) = try await task.value
					viewState = .success(containers)
				} catch {
					viewState = .failure(error)
					throw error
				}
			}

			self.suggestedSearchTokensTask?.cancel()
			self.suggestedSearchTokensTask = Task {
				let stacks = try await portainerStore.getStacks()
				let stacksTokens = stacks
					.filter { $0.status == .active }
					.sorted(by: \.name)
					.map { SearchToken.stack($0) }

				let statusTokens = [SearchToken.status(isOn: true), SearchToken.status(isOn: false)]

				self.suggestedSearchTokens = statusTokens + stacksTokens
			}

			try await self.fetchTask?.value
		}

		@MainActor
		func onLandingDismissed() {
			preferences.landingDisplayed = true
		}

		@MainActor
		func selectEndpoint(_ endpoint: Endpoint?) {
			portainerStore.selectEndpoint(endpoint)
		}
	}
}

// MARK: - ContentView.ViewModel+SearchToken

extension ContentView.ViewModel {
	enum SearchToken: Identifiable {
		case stack(Stack)
		case status(isOn: Bool)

		var id: String {
			switch self {
			case .stack(let stack):
				"stack:\(stack.id)"
			case .status(let isOn):
				"status:\(isOn)"
			}
		}

		var title: String {
			switch self {
			case .stack(let stack):
				stack.name
			case .status(let isOn):
				isOn ? String(localized: "ContentView.SearchToken.Status.On") : String(localized: "ContentView.SearchToken.Status.Off")
			}
		}

		var icon: String {
			switch self {
			case .stack:
				SFSymbol.stack
			case .status(let isOn):
				isOn ? SFSymbol.start : SFSymbol.stop
			}
		}

		func matches(container: Container) -> Bool {
			switch self {
			case .stack(let stack):
				return container.stack == stack.name
			case .status(let isOn):
				let state = container.state
				let isContainerOn = state == .created || state == .paused || state == .removing || state == .restarting || state == .running
				return isOn ? isContainerOn : !isContainerOn
			}
		}
	}
}

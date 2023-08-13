//
//  ContentView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
import PortainerKit
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ContentView+ViewModel

extension ContentView {
	@MainActor
	final class ViewModel: ObservableObject {
		private let portainerStore: PortainerStore
		private let preferences = Preferences.shared

		private var fetchTask: Task<Void, Error>?
		private var suggestedSearchTokensTask: Task<Void, Error>?

		@Published private(set) var viewState: ViewState<Void, Error> = .loading
		@Published private(set) var suggestedSearchTokens: [SearchToken] = []

		@Published var searchText = ""
		@Published var searchTokens: [SearchToken] = []
		@Published var isLandingSheetPresented = !Preferences.shared.landingDisplayed

		var containers: [Container] {
			portainerStore.containers
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
			!viewState.isLoading && containers.isEmpty
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
				self.viewState = .success(())
			}
		}

		func refresh() async throws {
			fetchTask?.cancel()
			self.fetchTask = Task {
				do {
					viewState = viewState.reloadingUnwrapped
					let task = portainerStore.refresh()
					_ = try await task.value
					viewState = .success(())
				} catch {
					viewState = .failure(error)
					throw error
				}
			}

			self.suggestedSearchTokensTask?.cancel()
			self.suggestedSearchTokensTask = Task {
				let staticTokens: [SearchToken] = [
					.status(isOn: true),
					.status(isOn: false)
				]

				let stacksTokens = try await portainerStore.getStacks()
					.filter { $0.status == .active }
					.sorted(by: \.name)
					.map { SearchToken.stack($0) }

				self.suggestedSearchTokens = staticTokens + stacksTokens
			}

			try await self.fetchTask?.value
		}

		func selectEndpoint(_ endpoint: Endpoint?) {
			portainerStore.selectEndpoint(endpoint)
		}

		func onLandingDismissed() {
			preferences.landingDisplayed = true
		}

		func onStackTapped(_ stack: Stack) {
			searchTokens = [.stack(stack)]
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
				String(localized: isOn ? "ContentView.SearchToken.Status.On" : "ContentView.SearchToken.Status.Off")
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
				let isContainerOn = container.state.isRunning
				return isOn ? isContainerOn : !isContainerOn
			}
		}
	}
}

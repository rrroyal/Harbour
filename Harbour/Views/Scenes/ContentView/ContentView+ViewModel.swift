//
//  ContentView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import Observation
import PortainerKit
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ContentView+ViewModel

extension ContentView {
	@Observable
	final class ViewModel: @unchecked Sendable {
		private let portainerStore: PortainerStore
		private let preferences = Preferences.shared

		private var fetchTask: Task<Void, Error>?
		private var suggestedSearchTokensTask: Task<Void, Error>?

		private(set) var suggestedSearchTokens: [SearchToken] = []

		var searchText = ""
		var searchTokens: [SearchToken] = []
//		var selectedStack: Stack? {
//			didSet {
//				if let selectedStack {
//					searchTokens = [.stack(selectedStack)]
//				} else {
//					searchTokens = []
//				}
//			}
//		}
		var isSearchActive = false
		var isLandingSheetPresented = !Preferences.shared.landingDisplayed

		@MainActor
		var viewState: ViewState<[Container], Error> {
			let containers = portainerStore.containers

			if !(fetchTask?.isCancelled ?? true) {
				return .reloading(containers)
			}

			if portainerStore.isRefreshing {
				return containers.isEmpty ? .loading : .reloading(containers)
			}

			return .success(containers)
		}

		@MainActor
		var containers: [Container] {
			portainerStore.containers
				.filter { container in
					for token in searchTokens {
						let matches = token.matchesContainer(container)
						if !matches { return false }
					}

					return true
				}
				.filter(searchText)
		}

		@MainActor
		var shouldShowEmptyPlaceholderView: Bool {
			switch viewState {
			case .loading:
				false
			case .reloading:
				false
			case .success:
				!viewState.isLoading && containers.isEmpty
			case .failure:
				false
			}
		}

		var shouldUseColumns: Bool {
			#if os(iOS)
			guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
				return false
			}
			#endif
			return preferences.cvUseColumns
		}

		var endpointsMenuTitle: String {
			if let selectedEndpoint = portainerStore.selectedEndpoint {
				return selectedEndpoint.name ?? selectedEndpoint.id.description
			}
			if portainerStore.endpoints.isEmpty {
				return String(localized: "ContentView.NoEndpointsAvailable")
			}
			return String(localized: "ContentView.NoEndpointSelected")
		}

		var canUseEndpointsMenu: Bool {
			portainerStore.selectedEndpoint != nil || !portainerStore.endpoints.isEmpty
		}

		var navigationTitle: String {
			if let selectedEndpoint = portainerStore.selectedEndpoint {
				return selectedEndpoint.name ?? selectedEndpoint.id.description
			}
			return String(localized: "AppName")
		}

		init() {
			let portainerStore = PortainerStore.shared
			self.portainerStore = portainerStore

//			self.viewState = {
//				if !portainerStore.containers.isEmpty {
//					if !(portainerStore.containersTask?.isCancelled ?? true) || !(portainerStore.endpointsTask?.isCancelled ?? true) {
//						return .reloading(())
//					} else {
//						return .success(())
//					}
//				}
//
//				/*
//				if !(portainerStore.setupTask?.isCancelled ?? true) {
//					return .loading
//				}
//				 */
//
//				return .success(())
//			}()
		}

		@MainActor
		func refresh() async throws {
			fetchTask?.cancel()
			self.fetchTask = Task {
				defer { self.fetchTask = nil }

				do {
//					viewState = viewState.reloading
					let task = portainerStore.refresh()
					_ = try await task.value
//					viewState = .success(())
				} catch {
//					viewState = .failure(error)
					throw error
				}
			}

			self.suggestedSearchTokensTask?.cancel()
			self.suggestedSearchTokensTask = Task {
				defer { self.suggestedSearchTokensTask = nil }

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

			async let fetchValue: Void? = fetchTask?.value
			async let suggestedSearchTokensValue: Void? = suggestedSearchTokensTask?.value

			_ = try await (fetchValue, suggestedSearchTokensValue)
		}

		@MainActor
		func selectEndpoint(_ endpoint: Endpoint?) {
			portainerStore.selectEndpoint(endpoint)
		}

		@MainActor
		func onLandingDismissed() {
			preferences.landingDisplayed = true
		}

		@MainActor
		func onStackTapped(_ stack: Stack?) {
			if let stack {
				searchTokens = [.stack(stack)]
			} else {
				searchTokens = []
			}
		}

//		@MainActor
//		func onContainersChange(_ before: [Container], after: [Container]) {
//			viewState = .success(())
//		}
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

		func matchesContainer(_ container: Container) -> Bool {
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

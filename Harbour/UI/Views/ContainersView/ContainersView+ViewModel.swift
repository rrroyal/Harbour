//
//  ContainersView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ContainersView+ViewModel

extension ContainersView {
	@Observable @MainActor
	final class ViewModel: @unchecked Sendable {
		private let portainerStore: PortainerStore
		private let preferences = Preferences.shared

		private var fetchTask: Task<Void, Error>?
		private var fetchError: Error?

		private(set) var suggestedSearchTokens: [SearchToken] = []

		var searchText = ""
		var searchTokens: [SearchToken] = []
		var isSearchActive = false
		var isLandingSheetPresented = !Preferences.shared.landingDisplayed
		var scrollViewIsRefreshing = false

		var viewState: ViewState<[Container], Error> {
			let containers = portainerStore.containers

			if !(fetchTask?.isCancelled ?? true) {
				return .reloading(containers)
			}

			if !(portainerStore.containersTask?.isCancelled ?? true) || !(portainerStore.endpointsTask?.isCancelled ?? true) {
				return containers.isEmpty ? .loading : .reloading(containers)
			}

			if let fetchError {
				return .failure(fetchError)
			}

			return .success(containers)
		}

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

		var isBackgroundPlaceholderVisible: Bool {
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

		var isStatusProgressViewVisible: Bool {
			!scrollViewIsRefreshing && viewState.showAdditionalLoadingView && !(fetchTask?.isCancelled ?? true)
		}

		var canUseEndpointsMenu: Bool {
			portainerStore.selectedEndpoint != nil || !portainerStore.endpoints.isEmpty
		}

		init() {
			let portainerStore = PortainerStore.shared
			self.portainerStore = portainerStore
		}

		func refresh() async throws {
			fetchTask?.cancel()
			self.fetchTask = Task {
				defer { self.fetchTask = nil }

				fetchError = nil

				do {
					async let endpointsTask = portainerStore.refreshEndpoints()
					async let containersTask = portainerStore.refreshContainers()

					_ = try await (endpointsTask.value, containersTask.value)

					let staticTokens: [SearchToken] = [
						.status(isOn: true),
						.status(isOn: false)
					]

					let stacks = Set(portainerStore.containers.compactMap(\.stack))
					let stacksTokens = stacks
						.sorted()
						.map { SearchToken.stack($0) }

					self.suggestedSearchTokens = staticTokens + stacksTokens
				} catch {
					fetchError = error
					throw error
				}
			}
			try await fetchTask?.value
		}

		func filterByStackName(_ stackName: String?) {
			if let stackName {
				searchTokens = [.stack(stackName)]
			} else {
				searchTokens = []
			}
		}

		func onLandingDismissed() {
			preferences.landingDisplayed = true
		}

//		@MainActor
//		func onContainersChange(_ before: [Container], after: [Container]) {
//			viewState = .success(())
//		}
	}
}

// MARK: - ContainersView.ViewModel+SearchToken

extension ContainersView.ViewModel {
	enum SearchToken: Identifiable, Equatable {
		case stack(String)
		case status(isOn: Bool)

		var id: String {
			switch self {
			case .stack(let stackName):
				"stack:\(stackName)"
			case .status(let isOn):
				"status:\(isOn)"
			}
		}

		var title: String {
			switch self {
			case .stack(let stackName):
				stackName
			case .status(let isOn):
				String(localized: isOn ? "ContainersView.SearchToken.Status.On" : "ContainersView.SearchToken.Status.Off")
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
			case .stack(let stackName):
				return container.stack == stackName
			case .status(let isOn):
				let isContainerOn = container.state.isRunning
				return isOn ? isContainerOn : !isContainerOn
			}
		}
	}
}

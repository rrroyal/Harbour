//
//  StacksView+ViewModel.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - StacksView+ViewModel

extension StacksView {
	@Observable
	final class ViewModel {
		private let portainerStore = PortainerStore.shared

		private var fetchTask: Task<Void, Error>?
		private var fetchError: Error?

		var query = ""
		var isSearchActive = false
		var scrollPosition: StackItem.ID?
//		var selectedStackID: StackItem.ID?
		var isCreateStackSheetPresented = false
		var activeCreateStackSheetDetent: PresentationDetent = .medium
		var scrollViewIsRefreshing = false

		var viewState: ViewState<[Stack], Error> {
			let stacks = portainerStore.stacks

			if !(fetchTask?.isCancelled ?? true) || !(portainerStore.stacksTask?.isCancelled ?? true) {
				return stacks.isEmpty ? .loading : .reloading(stacks)
			}

			if let fetchError {
				return .failure(fetchError)
			}

			return .success(stacks)
		}

		var stacks: [StackItem] {
			var stacks = portainerStore.stacks.map(StackItem.init)

			if Preferences.shared.svIncludeLimitedStacks {
				let realStackNames = Set(stacks.map(\.name))

				let limitedStackNames = portainerStore.containers
					.compactMap(\.stack)
					.filter { !realStackNames.contains($0) }
				let limitedStacks = Set(limitedStackNames)
					.map { StackItem(label: $0) }
				stacks += limitedStacks
			}

			if Preferences.shared.svFilterByActiveEndpoint, let selectedEndpointID = portainerStore.selectedEndpoint?.id {
				stacks = stacks.filter {
					// if there's no `stack.endpointID`, that means that this stack was derived from containers, which are already filtered by the active endpoint
					let stackEndpointID = $0.stack?.endpointID ?? selectedEndpointID
					return stackEndpointID == selectedEndpointID
				}
			}

			if !query.isReallyEmpty {
				stacks = stacks.filter {
					$0.name.localizedCaseInsensitiveContains(query) ||
					$0.id.description.localizedCaseInsensitiveContains(query)
				}
			}

			return stacks.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
		}

		var isBackgroundPlaceholderVisible: Bool {
			guard stacks.isEmpty else { return false }

			switch viewState {
			case .loading:
				return false
			case .reloading:
				return false
			case .success:
				return !viewState.isLoading && stacks.isEmpty
			case .failure:
				return false
			}
		}

		var isStatusProgressViewVisible: Bool {
			!scrollViewIsRefreshing && viewState.showAdditionalLoadingView && !(fetchTask?.isCancelled ?? true)
		}

		@discardableResult
		func fetch(includingContainers: Bool? = nil) -> Task<Void, Error> {
			fetchTask?.cancel()
			let task = Task { @MainActor in
				defer { self.fetchTask = nil }
				fetchError = nil

				do {
					if includingContainers ?? Preferences.shared.svIncludeLimitedStacks {
						async let _containers = portainerStore.refreshContainers().value
						async let _stacks = portainerStore.refreshStacks().value
						_ = try await (_containers, _stacks)
					} else {
						_ = try await portainerStore.refreshStacks().value
					}
				} catch {
					guard !error.isCancellationError else { return }
					fetchError = error
					throw error
				}
			}
			fetchTask = task
			return task
		}

		func setStackState(_ stackID: Stack.ID, started: Bool) async throws {
			try await portainerStore.setStackState(stackID: stackID, started: started)
			portainerStore.refreshContainers()
		}
	}
}

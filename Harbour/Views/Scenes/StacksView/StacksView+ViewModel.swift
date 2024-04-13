//
//  StacksView+ViewModel.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import Observation
import PortainerKit

// MARK: - StacksView+ViewModel

extension StacksView {
	@Observable
	final class ViewModel: Sendable {
		private let portainerStore = PortainerStore.shared

		private var refreshTask: Task<Void, Error>?

		private(set) var viewState: ViewState<[Stack], Error> = .loading
		private(set) var loadingStacks: Set<String> = []

		var query = ""

		var stacks: [StackItem]? {
			guard let realStacks = viewState.value?.compactMap(StackItem.init) else { return nil }
			let realStackNames = Set(realStacks.map(\.name))

			let limitedStackNames = portainerStore.containers
				.compactMap(\.stack)
				.filter { !realStackNames.contains($0) }
			let limitedStacks = Set(limitedStackNames)
				.map { StackItem(label: $0) }

			return realStacks + limitedStacks
		}

		var stacksFiltered: [StackItem]? {
			let allStacks = if query.isReallyEmpty {
				stacks
			} else {
				stacks?.filter {
					$0.name.localizedCaseInsensitiveContains(query) ||
					$0.id.description.localizedCaseInsensitiveContains(query)
				}
			}
			return allStacks?.sorted {
				$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
			}
		}

		var shouldShowEmptyPlaceholderView: Bool {
			stacksFiltered?.isEmpty ?? false
		}

		@MainActor
		func getStacks() async throws {
			refreshTask?.cancel()

			let task = Task {
				do {
					viewState = viewState.reloading

					if Preferences.shared.svIncludeLimitedStacks {
						async let _containers = portainerStore.refreshContainers().value
						async let _stacks = portainerStore.fetchStacks()
						let (_, stacks) = try await (_containers, _stacks)
						viewState = .success(stacks)
					} else {
						let stacks = try await portainerStore.fetchStacks()
						viewState = .success(stacks)
					}
				} catch {
					guard !error.isCancellationError else { return }
					viewState = .failure(error)
					throw error
				}
			}
			refreshTask = task

			try await task.value
		}

		@MainActor
		func setStackState(_ stack: Stack, started: Bool) async throws {
			loadingStacks.insert(stack.id.description)
			defer { loadingStacks.remove(stack.id.description) }

			try await portainerStore.setStackStatus(stackID: stack.id, started: started)

			let task = Task {
				if var stacks = self.viewState.value,
				   let stackIndex = stacks.firstIndex(where: { $0.id == stack.id }) {
					await MainActor.run {
						stacks[stackIndex].status = started ? .active : .inactive
						viewState = .success(stacks)
					}
				}

				try await getStacks()
			}
			try await task.value

			portainerStore.refreshContainers()
		}
	}
}

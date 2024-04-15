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
	final class ViewModel: Sendable {
		private let portainerStore = PortainerStore.shared

		private var refreshTask: Task<Void, Error>?

		private(set) var viewState: ViewState<Void, Error> = .loading
		private(set) var loadingStacks: Set<String> = []

		var query = ""

		var scrollPosition: StackItem.ID?

		var isCreateStackSheetPresented = false
		var activeCreateStackSheetDetent: PresentationDetent = .medium

		var stacks: [StackItem]? {
			let realStacks = portainerStore.stacks.map(StackItem.init)
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

		@MainActor @discardableResult
		func getStacks(includingContainers: Bool? = nil) -> Task<Void, Error> {
			refreshTask?.cancel()

			let task = Task {
				do {
					viewState = viewState.reloading

					if includingContainers ?? Preferences.shared.svIncludeLimitedStacks {
						async let _containers = portainerStore.refreshContainers().value
						async let _stacks = portainerStore.refreshStacks().value
						let (_, stacks) = try await (_containers, _stacks)

						guard !Task.isCancelled else { return }

						viewState = .success(())
					} else {
						_ = try await portainerStore.refreshStacks().value

						guard !Task.isCancelled else { return }

						viewState = .success(())
					}
				} catch {
					guard !error.isCancellationError else { return }
					viewState = .failure(error)
					throw error
				}
			}
			refreshTask = task
			return task
		}

		@MainActor
		func setStackState(_ stack: Stack, started: Bool) async throws {
			loadingStacks.insert(stack.id.description)
			defer { loadingStacks.remove(stack.id.description) }

			try await portainerStore.setStackStatus(stackID: stack.id, started: started)

			let task = Task {
				if var stacks = self.viewState.value,
				   let stackIndex = portainerStore.stacks.firstIndex(where: { $0.id == stack.id }) {
					await MainActor.run {
						portainerStore.stacks[stackIndex].status = started ? .active : .inactive
						viewState = .success(stacks)
					}
				}

				try await getStacks().value
			}
			try await task.value

			portainerStore.refreshContainers()
		}
	}
}

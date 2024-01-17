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
	final class ViewModel {
		private let portainerStore = PortainerStore.shared

		private var refreshTask: Task<Void, Error>?

		private(set) var viewState: ViewState<[Stack], Error> = .loading
		private(set) var loadingStacks: Set<Stack.ID> = []

		var searchText = ""

		@MainActor
		var stacks: [Stack]? {
			viewState.value?.filter(searchText)
		}

		@MainActor
		var shouldShowEmptyPlaceholderView: Bool {
			stacks?.isEmpty ?? false
		}

		@MainActor
		func getStacks() async throws {
			refreshTask?.cancel()

			let task = Task {
				do {
					viewState = viewState.reloading

					let stacks = try await portainerStore.getStacks()
					viewState = .success(stacks)
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
			loadingStacks.insert(stack.id)
			defer { loadingStacks.remove(stack.id) }

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
		}
	}
}

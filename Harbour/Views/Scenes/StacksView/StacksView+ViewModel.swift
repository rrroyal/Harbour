//
//  StacksView+ViewModel.swift
//  Harbour
//
//  Created by royal on 06/06/2023.
//

import Foundation
import Observation
import PortainerKit

// MARK: - StacksView+ViewModel

extension StacksView {
	final class ViewModel: ObservableObject {
		private let portainerStore = PortainerStore.shared

		private var refreshTask: Task<Void, Error>?

		@MainActor @Published private(set) var viewState: ViewState<[Stack], Error> = .loading
		@MainActor @Published private(set) var loadingStacks: Set<Stack.ID> = []

		@MainActor @Published var searchText = ""

		@MainActor
		var stacks: [Stack]? {
			viewState.unwrappedValue?.filter(searchText)
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
					viewState = viewState.reloadingUnwrapped

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
				if case .success(var stacks) = self.viewState,
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

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

		@Published private(set) var viewState: ViewState<[Stack], Error> = .loading
		@Published private(set) var loadingStacks: Set<Stack.ID> = []
		@Published var searchText = ""

		private var refreshTask: Task<Void, Never>?

		@MainActor
		func getStacks(errorHandler: ErrorHandler) async {
			refreshTask?.cancel()

			let task = Task {
				do {
					viewState = viewState.reloadingUnwrapped

					let stacks = try await portainerStore.getStacks()
					viewState = .success(stacks)
				} catch {
					guard !error.isCancellationError else { return }
					viewState = .failure(error)
					errorHandler(error)
				}
			}
			refreshTask = task

			await task.value
		}

		@MainActor
		func setStackStatus(_ stack: Stack, started: Bool, errorHandler: ErrorHandler) async {
			loadingStacks.insert(stack.id)
			defer { loadingStacks.remove(stack.id) }

			do {
				try await portainerStore.setStackStatus(stackID: stack.id, started: started)

				Task {
					if case .success(var stacks) = viewState,
					   let stackIndex = stacks.firstIndex(where: { $0.id == stack.id }) {
						await MainActor.run {
							stacks[stackIndex].status = started ? .active : .inactive
							viewState = .success(stacks)
						}
					}

					await getStacks(errorHandler: errorHandler)
				}
			} catch {
				errorHandler(error, ._debugInfo())
			}
		}
	}
}

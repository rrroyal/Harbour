//
//  StackDetailsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension StackDetailsView {
	@Observable
	final class ViewModel {
		private(set) var fetchTask: Task<Void, Error>?

		private(set) var viewState: ViewState<Stack, Error> = .loading

		var navigationItem: StackDetailsView.NavigationItem
		var stack: Stack? {
			viewState.value
		}

		init(navigationItem: StackDetailsView.NavigationItem) {
			self.navigationItem = navigationItem
		}

		func getStack() -> Task<Void, Error> {
			self.fetchTask?.cancel()
			let task: Task<Void, Error> = Task {
				do {
					viewState = viewState.reloading

					let stack = try await PortainerStore.shared.fetchStack(id: navigationItem.stackID)
					viewState = .success(stack)
				} catch {
					viewState = .failure(error)
					throw error
				}
			}
			self.fetchTask = task
			return task
		}
	}
}

//
//  StacksView+ContainersList.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//

import PortainerKit
import SwiftUI

// MARK: - StacksView+ContainersList

extension StacksView {
	struct ContainersList: View {
		@EnvironmentObject private var portainerStore: PortainerStore
		@Environment(\.errorHandler) private var errorHandler
		let stack: Stack

		@State private var searchText = ""
		@State private var viewState: ViewState<[Container], Error> = .loading
		@State private var refreshTask: Task<Void, Never>?

		private var containersFiltered: [Container] {
			if case .success(let containers) = viewState {
				return containers.filtered(searchText)
			}
			return []
		}

		var body: some View {
			let _containersFiltered = containersFiltered
			ScrollView {
				if case .success = viewState {
					ContainersView(containers: _containersFiltered)
						.transition(.opacity)
						.animation(.easeInOut, value: _containersFiltered.count)
				}
			}
			.background(ContainersView.NoContainersPlaceholder(isEmpty: _containersFiltered.isEmpty))
			.modifier(
				ContainersView.ListModifier {
					viewState.backgroundView
				}
			)
			.navigationTitle(stack.name)
			.transition(.opacity)
			.searchable(text: $searchText)
			.refreshable(action: refresh)
			.task(priority: .userInitiated, refresh)
		}
	}
}

// MARK: - StacksView.ContainersList+Actions

private extension StacksView.ContainersList {
	@Sendable
	func refresh() async {
		refreshTask?.cancel()
		let task = Task {
			viewState = .loading
			do {
				let containers = try await portainerStore.getContainers(for: stack.name)
				viewState = .success(containers)
			} catch {
				guard !error.isCancellationError else { return }
				errorHandler(error)
				viewState = .failure(error)
			}
		}
		refreshTask = task
		await task.value
	}
}

// MARK: - Previews

/*
 #Preview {
	StacksView.ContainersList()
 }
 */

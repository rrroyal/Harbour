//
//  SceneDelegate+PortainerActions.swift
//  Harbour
//
//  Created by royal on 26/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import PortainerKit

extension SceneDelegate {
	func removeContainer(_ container: Container) {
		Task {
			do {
				presentIndicator(.containerRemove(containerName: container.displayName ?? container.id, state: .loading))

				try await portainerStore.removeContainer(containerID: container.id, force: true)
				presentIndicator(.containerRemove(containerName: container.displayName ?? container.id, state: .success))

				navigate(to: .containers)
			} catch {
				presentIndicator(.containerRemove(containerName: container.displayName ?? container.id, state: .failure(error)))
				handleError(error, showIndicator: false)
			}
		}
	}

	func removeStack(_ stack: Stack) {
		Task {
			do {
				presentIndicator(.stackRemove(stackName: stack.name, state: .loading))

				try await portainerStore.removeStack(stackID: stack.id)
				portainerStore.refreshStacks()
				presentIndicator(.stackRemove(stackName: stack.name, state: .success))

				navigate(to: .stacks)
			} catch {
				presentIndicator(.stackRemove(stackName: stack.name, state: .failure(error)))
				handleError(error, showIndicator: false)
			}
		}
	}
}

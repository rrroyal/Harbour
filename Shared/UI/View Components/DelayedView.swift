//
//  DelayedView.swift
//  Harbour
//
//  Created by royal on 11/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - DelayedView

struct DelayedView<Content: View>: View {
	var isVisible: Bool
	var delay: Duration = .seconds(1)
	@ViewBuilder var content: () -> Content

	@State private var isVisibleAfterDelay = false
	@State private var task: Task<Void, Never>?

	var body: some View {
		if isVisible && !isVisibleAfterDelay {
			// swiftlint:disable:next redundant_discardable_let
			let _ = setupTask()
		}

		if isVisible && isVisibleAfterDelay {
			content()
				.onDisappear {
					isVisibleAfterDelay = false
					task?.cancel()
				}
		}
	}
}

// MARK: - DelayedView+Private

private extension DelayedView {
	func setupTask() {
		// I wonder when will it break
		DispatchQueue.main.async {
			self.isVisibleAfterDelay = false
			self.task?.cancel()
			self.task = Task {
				try? await Task.sleep(for: delay)
				guard isVisible && !Task.isCancelled else {
					self.task = nil
					return
				}

				self.isVisibleAfterDelay = true
			}
		}
	}
}

// MARK: - Previews

#Preview {
	DelayedView(isVisible: true) {
		ProgressView()
	}
}

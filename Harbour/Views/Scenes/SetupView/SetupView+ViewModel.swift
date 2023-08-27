//
//  SetupView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import Foundation
import Observation
import SwiftUI

// MARK: - SetupView+ViewModel

extension SetupView {
	@Observable
	final class ViewModel: Sendable {
		private let portainerStore: PortainerStore = .shared
		private let errorTimeoutInterval: TimeInterval = 3

		private(set) var isLoading = false
		private(set) var loginTask: Task<Void, Error>?
		private(set) var errorTimer: Timer?

		var url: String = ""
		var token: String = ""
		var buttonLabel: String?
		var buttonColor: Color?

		var canSubmit: Bool {
			!isLoading && !url.isReallyEmpty && !token.isReallyEmpty
		}

		init() { }

		func onViewDisappear() {
			errorTimer?.invalidate()
		}

		func onURLTextFieldEditingChanged(_ finished: Bool) {
			loginTask?.cancel()
		}

		func onURLTextFieldSubmit() {
			if !url.isReallyEmpty && !url.starts(with: "http") {
				Haptics.generateIfEnabled(.selectionChanged)
				url = "https://\(url)"
			}
		}

		func onTokenTextFieldSubmit(dismissAction: DismissAction?, errorHandler: ErrorHandler?) {
			guard canSubmit else { return }

			Haptics.generateIfEnabled(.light)
			login(dismissAction: dismissAction, errorHandler: errorHandler)
		}

		func onContinueButtonPress(dismissAction: DismissAction?, errorHandler: ErrorHandler?) {
			Haptics.generateIfEnabled(.light)
			login(dismissAction: dismissAction, errorHandler: errorHandler)
		}

		func login(dismissAction: DismissAction?, errorHandler: ErrorHandler?) {
			loginTask?.cancel()
			loginTask = Task { @MainActor in
				isLoading = true

				do {
					guard let url = URL(string: url) else {
						throw GenericError.invalidURL
					}

					try await portainerStore.setup(url: url, token: token)

					isLoading = false
					Haptics.generateIfEnabled(.success)

					buttonColor = .green
					buttonLabel = "SetupView.Button.Success"

					dismissAction?()
				} catch {
					isLoading = false

					buttonColor = .red
					buttonLabel = error.localizedDescription

					errorTimer?.invalidate()
					Task {
						try? await Task.sleep(for: .seconds(errorTimeoutInterval))
						await MainActor.run {
							self.buttonLabel = nil
							self.buttonColor = nil
						}
					}

					errorHandler?(error, ._debugInfo())

					throw error
				}
			}
		}

	}
}

// MARK: - SetupView.ViewModel+FocusedField {

extension SetupView.ViewModel {
	enum FocusedField {
		case url, token
	}
}

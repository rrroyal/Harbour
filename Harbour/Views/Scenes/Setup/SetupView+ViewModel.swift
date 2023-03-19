//
//  SetupView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
import SwiftUI
import CommonHaptics

// MARK: - SetupView+ViewModel

extension SetupView {
	@MainActor
	final class ViewModel: ObservableObject {
		private typealias Localization = Localizable.Setup

		private let portainerStore: PortainerStore = .shared

		private let errorTimeoutInterval: TimeInterval = 3

		@Published var url: String = ""
		@Published var token: String = ""

		@Published var buttonLabel: String?
		@Published var buttonColor: Color?

		@Published private(set) var isLoading = false
		@Published private(set) var loginTask: Task<Void, Error>?
		@Published private(set) var errorTimer: Timer?

		var canSubmit: Bool {
			!isLoading && !url.isReallyEmpty && !token.isReallyEmpty
		}

		init() {}

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

		func onTokenTextFieldSubmit(dismissAction: DismissAction?, errorHandler: SceneDelegate.ErrorHandler?) {
			guard canSubmit else { return }

			Haptics.generateIfEnabled(.light)
			login(dismissAction: dismissAction, errorHandler: errorHandler)
		}

		func onContinueButtonPress(dismissAction: DismissAction?, errorHandler: SceneDelegate.ErrorHandler?) {
			Haptics.generateIfEnabled(.light)
			login(dismissAction: dismissAction, errorHandler: errorHandler)
		}

		func login(dismissAction: DismissAction?, errorHandler: SceneDelegate.ErrorHandler?) {
			loginTask?.cancel()
			loginTask = Task {
				isLoading = true

				do {
					guard let url = URL(string: url) else {
						throw GenericError.invalidURL
					}

					try await portainerStore.setup(url: url, token: token)

					isLoading = false
					Haptics.generateIfEnabled(.success)

					buttonColor = .green
					buttonLabel = Localization.Button.success

					dismissAction?()
				} catch {
					isLoading = false
					Haptics.generateIfEnabled(.error)

					buttonColor = .red
					buttonLabel = error.localizedDescription

					errorTimer?.invalidate()
					errorTimer = Timer.scheduledTimer(withTimeInterval: errorTimeoutInterval, repeats: false) { [weak self] _ in
						DispatchQueue.main.async { [weak self] in
							self?.buttonLabel = nil
							self?.buttonColor = nil
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

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
	final class ViewModel: @unchecked Sendable {
		private let portainerStore = PortainerStore()
		private let errorTimeoutInterval: TimeInterval = 3

		private(set) var isLoading = false
		private(set) var loginTask: Task<Bool, Error>?
		private(set) var errorTimer: Timer?

		var url: String = ""
		var token: String = ""
		var buttonLabel: String?
		var buttonColor: Color?

		var canSubmit: Bool {
			!isLoading && !url.isReallyEmpty && !token.isReallyEmpty
		}

		init() { }

		func onURLTextFieldSubmit() {
			if !url.isReallyEmpty && !url.starts(with: "http") {
				Haptics.generateIfEnabled(.selectionChanged)
				url = "https://\(url)"
			}
		}

		@discardableResult
		func onTokenTextFieldSubmit() async throws -> Bool {
			guard canSubmit else { return false }

			Haptics.generateIfEnabled(.light)
			return try await login()
		}

		@discardableResult
		func onContinueButtonPress() async throws -> Bool {
			Haptics.generateIfEnabled(.light)
			return try await login()
		}

		func cancelLogin() {
			loginTask?.cancel()
			isLoading = false
		}

		@discardableResult
		func login() async throws -> Bool {
			cancelLogin()
			loginTask = Task { @MainActor in
				isLoading = true
				defer { isLoading = false }

				do {
					guard let url = URL(string: url) else {
						throw GenericError.invalidURL
					}

					let token = self.token

					try await portainerStore.setup(url: url, token: token, saveToken: false, _refresh: true)

					Haptics.generateIfEnabled(.success)

					buttonColor = .green
					buttonLabel = String(localized: "SetupView.LoginButton.Success")

					Task.detached {
						guard !Task.isCancelled else { return }
						try? await PortainerStore.shared.setup(url: url, token: token, saveToken: true, _refresh: true)
					}

					return true
				} catch {
					buttonColor = .red
					buttonLabel = error.localizedDescription

					errorTimer?.invalidate()

					Task {
						try? await Task.sleep(for: .seconds(errorTimeoutInterval))
						guard !Task.isCancelled else { return }
						await MainActor.run {
							self.buttonLabel = nil
							self.buttonColor = nil
						}
					}

					throw error
				}
			}
			return try await loginTask?.value ?? false
		}

		func onViewDisappear() {
			errorTimer?.invalidate()
			loginTask?.cancel()
		}
	}
}

// MARK: - SetupView.ViewModel+FocusedField {

extension SetupView.ViewModel {
	enum FocusedField {
		case url, token
	}
}

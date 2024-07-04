//
//  SetupView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import CommonOSLog
import OSLog
import PortainerKit
import SwiftUI

// MARK: - SetupView+ViewModel

extension SetupView {
	@Observable
	final class ViewModel {
		private let portainer = PortainerClient()
		private let logger = Logger(.custom(SetupView.self))

		@ObservationIgnored
		private var loginTask: Task<Bool, Error>?

		private(set) var viewState: ViewState<Bool, Error>?
		private(set) var errorTimer: Timer?

		var url: String = ""
		var token: String = ""
		var buttonLabel: String?
		var buttonColor: Color?

		var isLoading: Bool {
			viewState?.isLoading ?? false
		}

		var canSubmit: Bool {
			!isLoading && !url.isReallyEmpty && !token.isReallyEmpty
		}

		func onURLTextFieldSubmit() {
			if !url.isReallyEmpty && !url.starts(with: "http") {
				Haptics.generateIfEnabled(.selectionChanged)
				url = "https://\(url)"
			}
		}

		func cancelLogin() {
			viewState = nil
			loginTask?.cancel()
			loginTask = nil
		}

		func login() -> Task<Bool, Error> {
			logger.notice("Attempting to login with URL: \"\(self.url)\"...")

			cancelLogin()
			let task = Task {
				defer {
					self.loginTask = nil
				}

				viewState = .loading

				do {
					guard let url = URL(string: url) else {
						throw GenericError.invalidURL
					}

					let token = self.token

					portainer.serverURL = url
					portainer.token = token

					let endpoints = try await portainer.fetchEndpoints()
					logger.info("Got \(endpoints.count, privacy: .public) endpoint(s) from the new server, switching...")

					Task { @MainActor in
						guard !Task.isCancelled else { return }

						PortainerStore.shared.reset()
						PortainerStore.shared.setup(url: url, token: token, saveToken: true)

						PortainerStore.shared.setEndpoints(endpoints)
						if PortainerStore.shared.selectedEndpoint != nil {
							PortainerStore.shared.refreshContainers()
						}
					}

					Haptics.generateIfEnabled(.success)

					Task { @MainActor in
						buttonColor = .green
						buttonLabel = String(localized: "SetupView.LoginButton.Success")
						viewState = .success(true)
					}

					try? await Task.sleep(for: .seconds(1))

					return true
				} catch {
					Haptics.generateIfEnabled(.error)

					Task { @MainActor in
						buttonColor = .red
						buttonLabel = error.localizedDescription.localizedCapitalized
						viewState = .failure(error)
					}

					errorTimer?.invalidate()

					Task {
						try? await Task.sleep(for: .seconds(Constants.errorDismissTimeout))
						guard !Task.isCancelled else { return }
						await MainActor.run {
							self.buttonLabel = nil
							self.buttonColor = nil
							self.viewState = nil
						}
					}

					throw error
				}
			}
			self.loginTask = task
			return task
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

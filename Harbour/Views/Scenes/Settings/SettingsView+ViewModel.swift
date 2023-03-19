//
//  SettingsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 01/02/2023.
//

import Foundation
import UIKit.UIDevice

// MARK: - SettingsView+ViewModel

extension SettingsView {
	@MainActor
	final class ViewModel: ObservableObject {
		private let portainerStore: PortainerStore = .shared
		private let appState: AppState = .shared

		@Published var isSetupSheetPresented = false
		@Published var serverURLs: [URL]

		var activeURL: URL? {
			portainerStore.serverURL
		}

		var displayiPadOptions: Bool {
			UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad
		}

		init() {
			self.serverURLs = portainerStore.savedURLs
		}

		func refreshServers() {
			serverURLs = portainerStore.savedURLs
		}

		func switchPortainerServer(to serverURL: URL, errorHandler: SceneDelegate.ErrorHandler?) {
			appState.switchPortainerServer(to: serverURL, errorHandler: errorHandler)
		}

		func deleteServer(_ url: URL, errorHandler: SceneDelegate.ErrorHandler?) {
			do {
				if portainerStore.serverURL == url {
					portainerStore.reset()
				}

				try portainerStore.deleteServer(url)
				refreshServers()
			} catch {
				errorHandler?(error, ._debugInfo())
			}
		}
	}
}

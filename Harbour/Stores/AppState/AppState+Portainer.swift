//
//  AppState+Portainer.swift
//  Harbour
//
//  Created by royal on 29/10/2022.
//

import Foundation

extension AppState {
	@MainActor
	func switchPortainerServer(to serverURL: URL, errorHandler: SceneState.ErrorHandler?) {
		logger.info("Switching Portainer server to \"\(serverURL.absoluteString, privacy: .public)\" [\(String.debugInfo(), privacy: .public)]")

		portainerServerSwitchTask?.cancel()
		portainerServerSwitchTask = Task {
			do {
				try await PortainerStore.shared.switchServer(to: serverURL)
			} catch {
				logger.error("Failed to switch Portainer server: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
				errorHandler?(error, String.debugInfo())
				throw error
			}
		}
	}
}

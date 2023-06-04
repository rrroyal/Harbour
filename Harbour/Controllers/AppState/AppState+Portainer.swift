//
//  AppState+Portainer.swift
//  Harbour
//
//  Created by royal on 29/10/2022.
//

import Foundation
import WidgetKit
import CommonFoundation

extension AppState {
	@MainActor
	func switchPortainerServer(to serverURL: URL, errorHandler: SceneDelegate.ErrorHandler?) {
		logger.info("Switching Portainer server to \"\(serverURL.absoluteString, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

		portainerServerSwitchTask?.cancel()
		portainerServerSwitchTask = Task {
			let portainerStore = PortainerStore.shared
			do {
				try await portainerStore.switchServer(to: serverURL)
				try await portainerStore.refresh().value
			} catch {
				logger.error("Failed to switch Portainer server: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
				errorHandler?(error, String._debugInfo())
				throw error
			}

			WidgetCenter.shared.reloadAllTimelines()
		}
	}
}

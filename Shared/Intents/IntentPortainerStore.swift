//
//  IntentPortainerStore.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import KeychainKit
import OSLog
import PortainerKit

private let logger = Logger(.custom(IntentPortainerStore.self))

// MARK: - IntentPortainerStore

public final class IntentPortainerStore {
	nonisolated(unsafe) static let shared = IntentPortainerStore()

	public let portainer = PortainerClient(urlSessionConfiguration: .intents)

	public func setupIfNeeded() async throws {
		guard let urlStr = await Preferences.shared.selectedServer else {
			logger.warning("No selectedServer!")
			throw PortainerError.noServer
		}
		guard let url = URL(string: urlStr) else {
			logger.warning("selectedServer is not a valid URL: \(urlStr, privacy: .sensitive)")
			throw URLError(.badURL)
		}
		if portainer.serverURL == url { return }

		let token = try Keychain.shared.getString(for: url)
		portainer.serverURL = url
		portainer.token = token
	}
}

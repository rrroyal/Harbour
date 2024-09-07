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

	private let keychain = Keychain.shared

	public let portainer = PortainerClient(urlSessionConfiguration: .intents)

	public private(set) var isSetup = false

	public func setupIfNeeded() async throws {
		guard !isSetup else { return }

		guard let urlStr = await Preferences.shared.selectedServer else {
			throw PortainerError.noServer
		}
		guard let url = URL(string: urlStr) else {
			throw URLError(.badURL)
		}
		if portainer.serverURL == url { return }

		let token = try keychain.getString(for: url)
		portainer.serverURL = url
		portainer.token = token

		isSetup = true
	}
}

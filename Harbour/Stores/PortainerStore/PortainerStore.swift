//
//  PortainerStore.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Combine
import CommonFoundation
import CommonOSLog
import KeychainKit
import OSLog
import PortainerKit
import SwiftData

// MARK: - PortainerStore

/// Main store for Portainer-related data.
@MainActor @Observable
public final class PortainerStore {

	// MARK: Private properties

	internal let logger = Logger(.custom(PortainerStore.self))
	internal let keychain: Keychain
	internal let preferences: Preferences
	nonisolated(unsafe) internal let portainer: PortainerClient

	/// Persistence model context
	internal let modelActor: ModelActor?

	// MARK: Public properties

	/// Currently selected server URL
	var serverURL: URL? {
		portainer.serverURL
	}

	/// URLs with stored tokens
	var savedURLs: [URL] {
		(try? keychain.getSavedURLs()) ?? []
	}

	@ObservationIgnored
	private(set) var tasksController = TasksController()

	/// Is `PortainerStore` setup?
	var isSetup = false

	/// Currently selected endpoint's ID
	var selectedEndpoint: Endpoint? {
		didSet { onSelectedEndpointChange(selectedEndpoint) }
	}

	var endpoints: [Endpoint] = []

	var containers: [Container] = []

	var stacks: [Stack] = []

	var attachedContainer: AttachedContainer?

	var removedContainerIDs: Set<Container.ID> = []

	var loadingStackIDs: Set<Stack.ID> = []

	var removedStackIDs: Set<Stack.ID> = []

	var isRefreshing: Bool {
		tasksController.endpoints != nil || tasksController.containers != nil || tasksController.stacks != nil
	}

	// MARK: init

	/// Initializes `PortainerStore` with provided dependencies and URLSession configuration.
	/// - Parameters:
	///   - keychain: Keychain instance to use for credential storage
	///   - preferences: Preferences instance to use for user settings
	///   - urlSessionConfiguration: `URLSessionConfiguration`, `.app` if none
	init(
		keychain: Keychain = .shared,
		preferences: Preferences,
		urlSessionConfiguration: URLSessionConfiguration = .app
	) {
		self.keychain = keychain
		self.preferences = preferences
		self.portainer = PortainerClient(urlSessionConfiguration: urlSessionConfiguration)

		do {
			let modelContainer = try ModelContainer.default()
			self.modelActor = ModelActor(modelContext: ModelContext(modelContainer))

			if let storedEndpoints = fetchStoredEndpoints() {
				self.endpoints = storedEndpoints
				self.selectedEndpoint = storedEndpoints.first { $0.id == preferences.selectedEndpointID }
			}

			if let storedContainers = fetchStoredContainers() {
				self.containers = storedContainers
			}

			if let storedStacks = fetchStoredStacks() {
				self.stacks = storedStacks
			}
		} catch {
			logger.warning("Failed to create `ModelContainer`: \(error.localizedDescription, privacy: .public)")

			self.modelActor = nil
			if let selectedEndpointID = preferences.selectedEndpointID {
				self.selectedEndpoint = .init(id: selectedEndpointID)
			}
		}
	}
}

// MARK: PortainerStore+State

public extension PortainerStore {
	/// Sets up Portainer with provided credentials.
	/// - Parameters:
	///   - url: Server URL
	///   - token: Authorization token (if `nil`, it's searched in the keychain)
	///   - saveToken: Should the token be saved to the keychain?
	func setup(url: URL, token: String? = nil, saveToken: Bool = true) {
		logger.info("Setting up, URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\"...")

		let token = try? (token ?? keychain.getString(for: url))
		portainer.serverURL = url
		portainer.token = token

		if let token, saveToken {
			do {
				try keychain.setString(token, for: url, itemDescription: Keychain.tokenItemDescription)
			} catch {
				logger.error("Unable to save token to Keychain: \(error.localizedDescription, privacy: .public)")
			}
		}

		isSetup = true

//		logger.info("Setup with URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\" sucessfully!")
	}

	/// Sets up PortainerStore after init.
	func setupWithStored() {
		if let (url, token) = getStoredCredentials() {
			setup(url: url, token: token, saveToken: false)
		}
	}

	/// Switches server to provided `serverURL`.
	/// - Parameter serverURL: Server URL to switch to
	func switchServer(to serverURL: URL) {
		logger.notice("Switching to \"\(serverURL.absoluteString, privacy: .public)\"")

		reset()
		setup(url: serverURL, saveToken: false)

		preferences.selectedServer = serverURL

		logger.info("Switched successfully!")
	}

	/// Removes authorization data from Keychain for the provided server URL.
	/// - Parameter serverURL: Server URL to remove data for
	func removeServer(_ serverURL: URL) throws {
		logger.notice("Removing token for url: \"\(serverURL.absoluteString, privacy: .sensitive(mask: .hash))\"")
		do {
			try keychain.removeContent(for: serverURL)
//			logger.info("Removed token successfully!")
		} catch {
			logger.error("Failed to remove token: \(error.localizedDescription, privacy: .public)")
			throw error
		}
	}

	/// Resets the `PortainerStore` state.
	func reset() {
		logger.notice("Resetting state")

		isSetup = false

		portainer.serverURL = nil
		portainer.token = nil

		preferences.selectedEndpointID = nil
		preferences.selectedServer = nil

		selectedEndpoint = nil

		tasksController.endpoints?.cancel()
		setEndpoints(nil)

		tasksController.containers?.cancel()
		setContainers(nil)

		tasksController.stacks?.cancel()
		setStacks(nil)

		attachedContainer = nil
	}
}

// MARK: - PortainerStore+Set

extension PortainerStore {
	/// Selects the currently active endpoint.
	/// - Parameter endpoint: Endpoint to switch to
	func setSelectedEndpoint(_ endpoint: Endpoint?) {
		logger.notice("Selecting endpoint: \"\(endpoint?.name ?? "<none>", privacy: .sensitive(mask: .hash))\" (\(endpoint?.id.description ?? "<none>", privacy: .public))")
		self.selectedEndpoint = endpoint

		if endpoint != nil {
			refreshContainers()
		} else {
			tasksController.containers?.cancel()
			setEndpoints(nil)
			setContainers(nil)
		}
	}

	func setEndpoints(_ endpoints: [Endpoint]?) {
		self.endpoints = endpoints ?? []

		if let endpoints {
			if endpoints.count == 1 {
				selectedEndpoint = endpoints.first
			} else {
				selectedEndpoint = endpoints.first { $0.id == preferences.selectedEndpointID }
			}
		} else {
			containers = []
			selectedEndpoint = nil
		}

		storeEndpoints(endpoints)
	}

	func setContainers(_ containers: [Container]?) {
		let containers = (containers ?? []).sorted()
		self.containers = containers

		storeContainers(containers)
	}

	func setStacks(_ stacks: [Stack]?) {
		let stacks = (stacks ?? []).sorted()
		self.stacks = stacks

		storeStacks(stacks)
	}
}

// MARK: - PortainerStore+OnDidChange

extension PortainerStore {
	func onSelectedEndpointChange(_ selectedEndpoint: Endpoint?) {
		guard let selectedEndpoint else {
			preferences.selectedEndpointID = nil
			return
		}
		preferences.selectedEndpointID = selectedEndpoint.id
	}
}

//
//  AppState.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine
import UIKit.UIDevice
import os.log
import PortainerKit

@MainActor
final class AppState: ObservableObject {
	public static let shared: AppState = AppState()
	
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")
	
	private init() {
		if Preferences.shared.selectedServer != nil && Preferences.shared.autoRefreshInterval > 0 {
			setupAutoRefreshTimer()
		}
		
		containersCancellable = Portainer.shared.$containers
			.sink { self.handleContainersUpdate($0) }
	}
	
	// MARK: - Auto refresh
	
	internal var autoRefreshTimer: AnyCancellable? = nil

	/// Sets up `autoRefreshTimer` after updating `Preferences.autoRefreshInterval`
	public func setupAutoRefreshTimer(interval: Double = Preferences.shared.autoRefreshInterval) {
		logger.debug("(Auto refresh) Interval: \(interval, privacy: .public)")
		
		autoRefreshTimer?.cancel()

		if interval > 0 {
			autoRefreshTimer = Timer.publish(every: interval, on: .current, in: .common)
				.autoconnect()
				.receive(on: DispatchQueue.main)
				.sink { _ in
					Task { [weak self] in
						do {
							try await Portainer.shared.getContainers()
						} catch {
							self?.handle(error)
						}
					}
				}
		}
	}
	
	// MARK: - Quick actions
	
	private var lastOpenedContainers: [PortainerKit.Container] = []
	
	/// Updates `UIApplication.shortcutItems` after opening `ContainerDetailView`
	public func updateQuickActions(lastOpenedContainer container: PortainerKit.Container) {
		if let existingContainerIndex = lastOpenedContainers.firstIndex(where: { $0.id == container.id }) {
			lastOpenedContainers.remove(at: existingContainerIndex)
		}
		lastOpenedContainers.insert(container, at: 0)
		
		let containersCount = lastOpenedContainers.count
		if containersCount > 4 {
			lastOpenedContainers.removeLast(containersCount - 4)
		}
		
		let shortcutItems: [UIApplicationShortcutItem] = lastOpenedContainers.map { container in
			let userInfo: [String: NSSecureCoding] = [AppState.UserActivity.containerIDKey: container.id as NSSecureCoding]
			return UIApplicationShortcutItem(type: AppState.UserActivity.viewContainer, localizedTitle: container.displayName ?? container.id, localizedSubtitle: nil, icon: nil, userInfo: userInfo)
		}
		UIApplication.shared.shortcutItems = shortcutItems
	}
	
	private var containersCancellable: AnyCancellable? = nil
	
	/// Updates `UIApplication.shortcutItems` on `Portainer.containers` updates
	private func handleContainersUpdate(_ containers: [PortainerKit.Container]) {
		let containerIDs = containers.map(\.id)
		let shortcutItems = UIApplication.shared.shortcutItems?
			.filter {
				guard let containerID = $0.userInfo?[AppState.UserActivity.containerIDKey] as? String else { return false }
				return containerIDs.contains(containerID)
			}
		UIApplication.shared.shortcutItems = shortcutItems
	}
	
	// MARK: - Error handling
	
	private func handle(_ error: Error, _fileID: StaticString = #fileID, _line: Int = #line, _function: StaticString = #function) {
		logger.error("\(String(describing: error), privacy: .public) [\(_fileID, privacy: .public):\(_line, privacy: .public) \(_function, privacy: .public) ]")
	}
}

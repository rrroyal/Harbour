//
//  AppNotifications.swift
//	AppNotifications
//
//  Created by unitears on 13/06/2021.
//

import Combine
import Foundation
import SwiftUI

// TODO: Test @MainActor

@available(iOS 15.0, macOS 12.0, *)
public final class AppNotifications: ObservableObject {
	
	// MARK: - Properties
	
	@Published public private(set) var activeNotifications: [Notification] = [] {
		didSet { updateTimer() }
	}

	private var timerCancellable: AnyCancellable? = nil
	
	// MARK: - init
	
	public init() {}
	
	// MARK: - Public functions
	
	/// Adds new notification.
	/// - Parameters:
	///   - notification: Notification to add
	///   - index: Insertion index
	@MainActor public func add(_ notification: Notification, at index: Int = 0) {
		notification.isVisible = true
		activeNotifications.insert(notification, at: index)
		if index == 0 { updateTimer() }
	}
	
	/// Adds new notifications.
	/// - Parameters:
	///   - notifications: Notifications to add
	///   - index: Insertion index
	@MainActor public func add(_ notifications: [Notification], at index: Int = 0) {
		notifications.forEach { $0.isVisible = true }
		self.activeNotifications.insert(contentsOf: notifications, at: index)
		if index == 0 { self.updateTimer() }
	}
	
	/// Dismisses all notifications with matching ID
	/// - Parameter match: ID to match
	@MainActor public func dismiss(matching match: String) {
		let notifications = activeNotifications.filter { $0.id == match }
		notifications.forEach { dismiss($0) }
	}
	
	/// Dismisses the provided notification.
	/// - Parameter notification: Notification to dismiss
	@MainActor public func dismiss(_ notification: Notification) {
		guard let index = self.activeNotifications.firstIndex(of: notification) else { return }
		
		self.activeNotifications[index].isVisible = false
		self.activeNotifications.remove(at: index)
	}
	
	// MARK: - Private functions
	
	/// Updates the dismiss timer.
	private func updateTimer() {
		guard let nextNotification = activeNotifications.first else {
			cancelTimer()
			return
		}
		
		switch nextNotification.dismissType {
			case .manual, .none:
				cancelTimer()
			case .timeout(let timeout):
				timerCancellable = Timer.publish(every: timeout, on: .main, in: .common)
					.autoconnect()
					.receive(on: DispatchQueue.main)
					.sink { [weak self] _ in
						guard let self = self else { return }
						
						guard !self.activeNotifications.isEmpty else {
							self.cancelTimer()
							return
						}
						
						self.activeNotifications[0].isVisible = false
						self.activeNotifications.remove(at: 0)
					}
		}
	}
	
	/// Cancels the dismiss timer.
	private func cancelTimer() {
		timerCancellable?.cancel()
		timerCancellable = nil
	}
	
}

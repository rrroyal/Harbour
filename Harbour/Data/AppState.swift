//
//  AppState.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import Foundation
import Combine
import os.log
import UIKit
import AppNotifications

class AppState: ObservableObject {
	public static let shared: AppState = AppState()

	@Published public var activeContainerDetail: String? = nil
	@Published public var isContainerConsoleSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = false
	
	public var activeNetworkActivities: Set<String> = [] {
		didSet { UIApplication.shared.setLoadingIndicatorActive(!activeNetworkActivities.isEmpty) }
	}
	
	public let errorNotifications: AppNotifications = AppNotifications()
	public let persistenceNotifications: AppNotifications = AppNotifications()

	private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").AppState", category: "AppState")
	
	private var autoRefreshTimer: AnyCancellable? = nil

	private init() {
		if !Preferences.shared.launchedBefore {
			isSetupSheetPresented = true
		}
		
		if Preferences.shared.autoRefreshInterval > 0 {
			setupAutoRefreshTimer()
		}
	}
	
	// MARK: - Auto refresh
	
	public func setupAutoRefreshTimer(interval: Double = Preferences.shared.autoRefreshInterval) {
		self.logger.debug("(Auto refresh) Interval: \(interval)")
		
		autoRefreshTimer?.cancel()

		guard interval > 0 else {
			autoRefreshTimer = nil
			return
		}
		
		autoRefreshTimer = Timer.publish(every: interval, on: .current, in: .common)
			.autoconnect()
			.sink { _ in
				Task {
					do {
						guard let selectedEndpointID = Portainer.shared.selectedEndpoint?.id else {
							return
						}
						
						try await Portainer.shared.getContainers(endpointID: selectedEndpointID)
					} catch {
						await UIDevice.current.generateHaptic(.error)
						self.handle(error)
					}
				}
			}
	}
	
	// MARK: - Error handling
	
	public func handle(_ error: Error, notification: AppNotifications.Notification, _fileID: StaticString = #fileID, _line: Int = #line) {
		handle(error, displayNotification: false, _fileID: _fileID, _line: _line)
		DispatchQueue.main.async { [weak self] in
			self?.errorNotifications.add(notification)
		}
	}

	public func handle(_ error: Error, displayNotification: Bool = true, _fileID: StaticString = #fileID, _line: Int = #line) {
		UIDevice.current.generateHaptic(.error)
		logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")
		
		if displayNotification {
			let notification: AppNotifications.Notification = .init(id: UUID().uuidString, dismissType: .timeout(5), icon: "exclamationmark.triangle", title: "Error!", description: error.localizedDescription, backgroundStyle: .colorAndMaterial(color: .red.opacity(0.5), material: .regularMaterial))
			DispatchQueue.main.async { [weak self] in
				self?.errorNotifications.add(notification)
			}
		}
	}
}

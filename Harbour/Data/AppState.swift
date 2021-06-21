//
//  AppState.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import os.log
import AppNotifications
import UIKit

class AppState: ObservableObject {
	public static let shared: AppState = AppState()

	@Published public var isContainerConsoleSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = false
	
	public var activeNetworkActivities: Set<String> = [] {
		didSet { UIApplication.shared.setLoadingIndicatorActive(!activeNetworkActivities.isEmpty) }
	}
	
	public let errorNotifications: AppNotifications = AppNotifications()
	public let persistenceNotifications: AppNotifications = AppNotifications()

	private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").AppState", category: "AppState")

	private init() {
		if !Preferences.shared.launchedBefore { isSetupSheetPresented = true }
	}

	public func handle(_ error: Error, displayNotification: Bool = true, _fileID: StaticString = #fileID, _line: Int = #line) {
		self.logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")
		
		if displayNotification {
			let notification: AppNotifications.Notification = .init(id: UUID().uuidString, dismissType: .timeout(5), icon: "exclamationmark.triangle", title: "Error!", description: error.localizedDescription, backgroundStyle: .colorAndMaterial(color: .red.opacity(0.5), material: .regularMaterial))
			errorNotifications.add(notification)
		}
	}
	
	public func handle(_ error: Error, notification: AppNotifications.Notification, _fileID: StaticString = #fileID, _line: Int = #line) {
		self.handle(error, displayNotification: false, _fileID: _fileID, _line: _line)
		errorNotifications.add(notification)
	}
}

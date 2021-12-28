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
import Indicators

class AppState: ObservableObject {
	public static let shared: AppState = AppState()
	
	@Published public var fetchingMainScreenData: Bool = false
	
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")
	
	internal var autoRefreshTimer: AnyCancellable? = nil

	private init() {
		if Preferences.shared.selectedServer != nil && Preferences.shared.autoRefreshInterval > 0 {
			setupAutoRefreshTimer()
		}
	}
	
	// MARK: - Auto refresh
	
	public func setupAutoRefreshTimer(interval: Double = Preferences.shared.autoRefreshInterval) {
		logger.debug("(Auto refresh) Interval: \(interval)")
		
		autoRefreshTimer?.cancel()

		guard interval > 0 else { return }
		
		autoRefreshTimer = Timer.publish(every: interval, on: .current, in: .common)
			.autoconnect()
			.receive(on: DispatchQueue.main)
			.sink { _ in
				Task { [weak self] in
					self?.fetchingMainScreenData = true
					
					do {
						try await Portainer.shared.getContainers()
					} catch {
						self?.handle(error)
					}
					
					self?.fetchingMainScreenData = false
				}
			}
	}
	
	// MARK: - Error handling
	
	private func handle(_ error: Error, _fileID: StaticString = #fileID, _line: Int = #line) {
		logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")
	}
}

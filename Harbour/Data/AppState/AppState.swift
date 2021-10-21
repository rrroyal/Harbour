//
//  AppState.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine
import os.log
import Indicators

class AppState: ObservableObject {
	public static let shared: AppState = AppState()
	
	@Published public var fetchingMainScreenData: Bool = false
	
	public let indicators: Indicators = Indicators()

	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")
	
	internal var autoRefreshTimer: AnyCancellable? = nil

	private init() {
		#if DEBUG
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		#endif
		
		if Preferences.shared.endpointURL != nil && Preferences.shared.autoRefreshInterval > 0 {
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
			.sink { _ in
				Task { [weak self] in
					DispatchQueue.main.async { [weak self] in
						self?.fetchingMainScreenData = true
					}
					
					do {
						try await Portainer.shared.getContainers()
					} catch {
						self?.handle(error)
					}
					
					DispatchQueue.main.async { [weak self] in
						self?.fetchingMainScreenData = false
					}
				}
			}
	}
}
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
	
	// MARK: - Attached container
	
	func onContainerConsoleViewDismissed() {
		guard Preferences.shared.persistAttachedContainer else {
			Portainer.shared.attachedContainer = nil
			return
		}
		
		if Preferences.shared.displayContainerDismissedPrompt && Portainer.shared.attachedContainer != nil {
			let indicatorID: String = "ContainerDismissedIndicator"
			let indicator: Indicators.Indicator = .init(id: indicatorID, icon: "terminal.fill", headline: Localization.CONTAINER_DISMISSED_INDICATOR_TITLE.localized, subheadline: Localization.CONTAINER_DISMISSED_INDICATOR_DESCRIPTION.localized, dismissType: .after(5), onTap: {
				self.showAttachedContainer()
				self.indicators.dismiss(matching: indicatorID)
			})
			indicators.display(indicator)
		}
	}
	
	func showAttachedContainer() {
		guard Portainer.shared.attachedContainer != nil else {
			return
		}
		
		UIDevice.current.generateHaptic(.light)
		NotificationCenter.default.post(name: .ShowAttachedContainer, object: nil)
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

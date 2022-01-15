//
//  SceneState.swift
//  Harbour
//
//  Created by royal on 22/10/2021.
//

import Foundation
import os.log
import UIKit.UIDevice
import Indicators
import PortainerKit

final class SceneState: ObservableObject {
	public typealias ErrorHandler = (Error, Indicators.Indicator?, StaticString, Int) -> ()
	
	@Published public var isSettingsSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = !Preferences.shared.finishedSetup
	@Published public var isContainerConsoleSheetPresented: Bool = false
	
	@Published public var activeContainerID: String? = nil
	
	public let indicators = Indicators()
	
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SceneState")
	
	// MARK: - User activity
	@MainActor public func handleContinueUserActivity(_ activity: NSUserActivity) {
		logger.debug("Continuing UserActivity \"\(activity.activityType)\"")
		
		do {
			switch activity.activityType {
				case AppState.UserActivity.attachToContainer:
					if let containerID = activity.userInfo?[AppState.UserActivity.containerIDKey] as? String,
					   let container = Portainer.shared.containers.first(where: { $0.id == containerID }) {
						try Portainer.shared.attach(to: container, endpointID: activity.userInfo?[AppState.UserActivity.endpointIDKey] as? Int)
					}
				case AppState.UserActivity.viewContainer:
					if let containerID = activity.userInfo?[AppState.UserActivity.containerIDKey] as? String {
						activeContainerID = containerID
					}
				default:
					break
			}
		} catch {
			handle(error)
		}
	}
	
	// MARK: - Attached container
	
	@MainActor public func onContainerConsoleViewDismissed() {
		guard Preferences.shared.persistAttachedContainer else {
			Portainer.shared.attachedContainer = nil
			return
		}
		
		guard let attachedContainer = Portainer.shared.attachedContainer else {
			return
		}
				
		if attachedContainer.isConnected {
			let indicatorID: String = "ContainerDismissedIndicator"
			let indicator: Indicators.Indicator = .init(id: indicatorID,
														icon: "terminal.fill",
														headline: Localization.CONTAINER_DISMISSED_INDICATOR_TITLE.localized,
														subheadline: Localization.CONTAINER_DISMISSED_INDICATOR_DESCRIPTION.localized,
														dismissType: .after(5),
														onTap: { [weak self] in
															self?.showAttachedContainer()
															self?.indicators.dismiss(matching: indicatorID)
														})
			indicators.display(indicator)
		}
	}
	
	@MainActor public func showAttachedContainer() {
		guard Portainer.shared.attachedContainer?.isConnected ?? false else {
			return
		}
		
		UIDevice.generateHaptic(.light)
		isContainerConsoleSheetPresented = true
	}
	
	// MARK: - Error handling
	
	public func handle(_ error: Error, indicator: Indicators.Indicator, _fileID: StaticString = #fileID, _line: Int = #line) {
		handle(error, displayIndicator: false, _fileID: _fileID, _line: _line)
		
		DispatchQueue.main.async {
			self.indicators.display(indicator)
		}
	}
	
	public func handle(_ error: Error, displayIndicator: Bool = true, _fileID: StaticString = #fileID, _line: Int = #line) {
		if error as? PortainerKit.APIError == PortainerKit.APIError.invalidJWTToken { return }
		
		UIDevice.generateHaptic(.error)
		logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")
		
		if displayIndicator {
			let style: Indicators.Indicator.Style = .init(subheadlineColor: .red, subheadlineStyle: .primary, iconColor: .red, iconStyle: .primary)
			let indicator: Indicators.Indicator = .init(id: UUID().uuidString, icon: "exclamationmark.triangle.fill", headline: "Error!", subheadline: error.localizedDescription, expandedText: error.localizedDescription, dismissType: .after(5), style: style)
			DispatchQueue.main.async {
				self.indicators.display(indicator)
			}
		}
	}
}

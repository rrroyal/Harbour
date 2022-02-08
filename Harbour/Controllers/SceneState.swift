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

@MainActor
final class SceneState: ObservableObject {
	public typealias ErrorHandler = (Error, Indicators.Indicator?, StaticString, Int, StaticString) -> ()
	
	@Published public var isSettingsSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = !Preferences.shared.finishedSetup
	@Published public var isContainerConsoleSheetPresented: Bool = false
	
	@Published public var activeContainer: PortainerKit.Container? = nil {
		didSet {
			guard let container = activeContainer else { return }
			AppState.shared.updateQuickActions(lastOpenedContainer: container)
		}
	}
	
	public let indicators = Indicators()
	
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SceneState")
	
	public func onOpenURL(_ url: URL) {
		logger.notice("Opening URL \"\(url.absoluteString, privacy: .public)\"")

		guard let action = HarbourURLScheme.fromURL(url) else { return }

		print(action)

		switch action {
			case .openContainer(let containerID):
				if let container = Portainer.shared.containers.first(where: { $0.id == containerID }) {
					activeContainer = container
				}
		}
	}
	
	// MARK: - User activity
	@MainActor public func handleContinueUserActivity(_ activity: NSUserActivity) {
		logger.notice("Continuing UserActivity \"\(activity.activityType, privacy: .public)\"")
		
		do {
			switch activity.activityType {
				case AppState.UserActivity.attachToContainer:
					if let containerID = activity.userInfo?[AppState.UserActivity.containerIDKey] as? String,
					   let container = Portainer.shared.containers.first(where: { $0.id == containerID }) {
						try Portainer.shared.attach(to: container, endpointID: activity.userInfo?[AppState.UserActivity.endpointIDKey] as? Int)
					}
				case AppState.UserActivity.viewContainer:
					if let containerID = activity.userInfo?[AppState.UserActivity.containerIDKey] as? String,
					   let container = Portainer.shared.containers.first(where: { $0.id == containerID }) {
						activeContainer = container
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
														headline: Localization.Indicator.ContainerDismissed.title,
														subheadline: Localization.Indicator.ContainerDismissed.description,
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
	
	public func handle(_ error: Error, indicator: Indicators.Indicator, _fileID: StaticString = #fileID, _line: Int = #line, _function: StaticString = #function) {
		handle(error, displayIndicator: false, _fileID: _fileID, _line: _line, _function: _function)
		
		DispatchQueue.main.async {
			self.indicators.display(indicator)
		}
	}
	
	public func handle(_ error: Error, displayIndicator: Bool = true, _fileID: StaticString = #fileID, _line: Int = #line, _function: StaticString = #function) {
//		if error as? PortainerKit.APIError == PortainerKit.APIError.invalidJWTToken { return }
		
		UIDevice.generateHaptic(.error)
		logger.error("\(String(describing: error), privacy: .public) [\(_fileID, privacy: .public):\(_line, privacy: .public) \(_function, privacy: .public)]")
		
		let errorDescription = error.readableDescription
		let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion
		
		if displayIndicator {
			let style: Indicators.Indicator.Style = .init(subheadlineColor: .red, subheadlineStyle: .primary, iconColor: .red, iconStyle: .primary)
			let indicator: Indicators.Indicator = .init(id: UUID().uuidString, icon: "exclamationmark.triangle.fill", headline: "Error!", subheadline: errorDescription, expandedText: recoverySuggestion ?? errorDescription, dismissType: .after(5), style: style)
			DispatchQueue.main.async {
				self.indicators.display(indicator)
			}
		}
	}
}

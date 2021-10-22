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

class SceneState: ObservableObject {
	@Published public var isSettingsSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = !Preferences.shared.finishedSetup
	@Published public var isContainerConsoleSheetPresented: Bool = false
	
	public let indicators = Indicators()
	
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SceneState")
	
	// MARK: - Attached container
	
	func onContainerConsoleViewDismissed() {
		guard Preferences.shared.persistAttachedContainer else {
			Portainer.shared.attachedContainer = nil
			return
		}
		
		guard let attachedContainer = Portainer.shared.attachedContainer else {
			return
		}
				
		if Preferences.shared.displayContainerDismissedPrompt && attachedContainer.isConnected {
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
	
	func showAttachedContainer() {
		guard Portainer.shared.attachedContainer?.isConnected ?? false else {
			return
		}
		
		UIDevice.current.generateHaptic(.light)
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
		UIDevice.current.generateHaptic(.error)
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

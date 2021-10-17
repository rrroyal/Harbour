//
//  AppState+Errors.swift
//  Harbour
//
//  Created by royal on 17/10/2021.
//

import Foundation
import UIKit.UIDevice
import Indicators

extension AppState {
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

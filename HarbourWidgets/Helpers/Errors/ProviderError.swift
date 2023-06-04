//
//  ProviderError.swift
//  HarbourWidgets
//
//  Created by royal on 28/11/2022.
//

import Foundation

enum ProviderError: LocalizedError {
	case containerNotFound

	var shouldDisplayErrorView: Bool {
		switch self {
		case .containerNotFound:
			return false
		}
	}

	var widgetPlaceholder: String {
		switch self {
		case .containerNotFound:
			return Localizable.Widgets.notFoundPlaceholder
		}
	}
}

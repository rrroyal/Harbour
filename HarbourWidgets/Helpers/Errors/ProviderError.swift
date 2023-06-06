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
			false
		}
	}

	var widgetPlaceholder: String {
		switch self {
		case .containerNotFound:
			Localizable.Widget.notFoundPlaceholder
		}
	}
}

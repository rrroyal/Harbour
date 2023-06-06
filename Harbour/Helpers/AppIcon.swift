//
//  AppIcon.swift
//  Harbour
//
//  Created by royal on 09/06/2023.
//

import UIKit

struct AppIcon: Identifiable {
	let id: String?
	let name: String
}

extension AppIcon {
	private typealias Localization = Localizable.AppIcon

	static let `default`: Self = .init(id: nil, name: Localization.default)
	static let boxLight: Self = .init(id: "AppIcon-Box-Light", name: Localization.boxLight)
	static let boxDark: Self = .init(id: "AppIcon-Box-Dark", name: Localization.boxDark)
	static let ogLight: Self = .init(id: "AppIcon-OG-Light", name: Localization.ogLight)
	static let ogDark: Self = .init(id: "AppIcon-OG-Dark", name: Localization.ogDark)

	static let allCases: [Self] = [
		.default,
		.boxLight,
		.boxDark,
		.ogLight,
		.ogDark
	]
}

extension AppIcon {
	static var current: Self {
		allCases.first { $0.id == UIApplication.shared.alternateIconName } ?? .default
	}
}

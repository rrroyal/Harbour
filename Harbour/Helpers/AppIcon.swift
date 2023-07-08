//
//  AppIcon.swift
//  Harbour
//
//  Created by royal on 09/06/2023.
//

#if canImport(UIKit)
import UIKit
#endif

// MARK: - AppIcon

struct AppIcon: Identifiable, Equatable {
	let id: String?
	let name: String

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - AppIcon+setIcon

extension AppIcon {
	static func setIcon(_ icon: AppIcon) async throws {
		#if canImport(UIKit)
		try await UIApplication.shared.setAlternateIconName(icon.id)
		#endif
	}
}

// MARK: - AppIcon+icons

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

// MARK: - AppIcon+current

extension AppIcon {
	static var current: Self {
		#if os(iOS)
		allCases.first { $0.id == UIApplication.shared.alternateIconName } ?? .default
		#else
		.default
		#endif
	}
}

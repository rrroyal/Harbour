//
//  AppIcon.swift
//  Harbour
//
//  Created by royal on 09/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

// MARK: - AppIcon

struct AppIcon: Equatable, Hashable, Identifiable {
	let id: String?
	let name: String

	private init(id: String?, name: String) {
		self.id = id
		self.name = name
	}
}

// MARK: - AppIcon+setIcon

#if canImport(UIKit)
extension AppIcon {
	@MainActor
	static func setIcon(_ icon: AppIcon) async throws {
		try await UIApplication.shared.setAlternateIconName(icon.id)
	}
}
#endif

// MARK: - AppIcon+icons

extension AppIcon {
	static let `default`: Self = .init(id: nil, name: String(localized: "AppIcon.Default"))
	static let boxLight: Self = .init(id: "AppIcon-Box-Light", name: String(localized: "AppIcon.BoxLight"))
	static let boxDark: Self = .init(id: "AppIcon-Box-Dark", name: String(localized: "AppIcon.BoxDark"))
	static let ogLight: Self = .init(id: "AppIcon-OG-Light", name: String(localized: "AppIcon.OGLight"))
	static let ogDark: Self = .init(id: "AppIcon-OG-Dark", name: String(localized: "AppIcon.OGDark"))

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
		#if canImport(UIKit)
		if let alternateIconName = UIApplication.shared.alternateIconName {
			return allCases.first { $0.id == alternateIconName } ?? .default
		} else {
			return .default
		}
		#else
		.default
		#endif
	}
}

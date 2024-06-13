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
	static let box: Self = .init(id: "AppIcon-Box", name: String(localized: "AppIcon.Box"))
	static let og: Self = .init(id: "AppIcon-OG", name: String(localized: "AppIcon.OG"))

	static let allCases: [Self] = [
		.default,
		.box,
		.og,
	]
}

// MARK: - AppIcon+current

extension AppIcon {
	@MainActor
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

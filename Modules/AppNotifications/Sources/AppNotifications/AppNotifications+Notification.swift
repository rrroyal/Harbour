//
//  AppNotifications+Notification.swift
//  AppNotifications
//
//  Created by unitears on 13/06/2021.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public extension AppNotifications {
	class Notification: ObservableObject, Identifiable, Equatable {
		public init(
			id: String,
			dismissType: DismissType,
			icon: String?,
			title: String,
			description: String? = nil,
			foregroundColor: Color = .primary,
			backgroundStyle: BackgroundStyle = .material(.regular),
			onTap: (() -> Void)? = nil
		) {
			self.id = id
			self.dismissType = dismissType
			self.icon = icon
			self.title = title
			self.description = description
			self.foregroundColor = foregroundColor
			self.backgroundStyle = backgroundStyle
			self.onTap = onTap
		}
		
		public let id: String
		
		public let dismissType: DismissType

		public let icon: String?
		
		public let title: String
		public let description: String?
		
		public let foregroundColor: Color
		public let backgroundStyle: BackgroundStyle
		
		public let onTap: (() -> Void)?
		
		@Published public var isVisible: Bool = false
		
		public static func == (lhs: AppNotifications.Notification, rhs: AppNotifications.Notification) -> Bool {
			lhs.id == rhs.id
		}
	}
}

@available(iOS 15.0, macOS 12.0, *)
public extension AppNotifications.Notification {
	enum DismissType: Equatable {
		case none
		case manual
		case timeout(_ timeout: TimeInterval)
	}
	
	enum BackgroundStyle {
		case color(_ color: Color)
		case material(_ material: Material)
		case colorAndMaterial(color: Color, material: Material)
	}
}

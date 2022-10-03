//
//  Indicator.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - Indicator

public struct Indicator: Identifiable {
	public let id: String

	public let icon: String?
	public let headline: String
	public let subheadline: String?
	public let expandedText: String?
	public let dismissType: DismissType
	public let style: Style
	public let onTap: (() -> Void)?

	public init(id: String,
				icon: String? = nil,
				headline: String,
				subheadline: String? = nil,
				expandedText: String? = nil,
				dismissType: DismissType,
				style: Style = .default,
				onTap: (() -> Void)? = nil
	) {
		self.id = id
		self.icon = icon
		self.headline = headline
		self.subheadline = subheadline
		self.expandedText = expandedText
		self.dismissType = dismissType
		self.style = style
		self.onTap = onTap
	}
}

// MARK: - Indicator+Hashable

extension Indicator: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

// MARK: - Indicator+Equatable

extension Indicator: Equatable {
	public static func == (lhs: Indicator, rhs: Indicator) -> Bool {
		lhs.id == rhs.id &&
		lhs.headline == rhs.headline &&
		lhs.subheadline == rhs.subheadline &&
		lhs.icon == rhs.icon &&
		lhs.expandedText == rhs.expandedText
	}
}

// MARK: - Indicator+

public extension Indicator {
	enum DismissType {
		case manual
		case after(TimeInterval)

		public static let automatic: DismissType = .after(5)
	}

	struct Style {
		public var headlineColor: Color?
		public var headlineStyle: HierarchicalShapeStyle

		public var subheadlineColor: Color?
		public var subheadlineStyle: HierarchicalShapeStyle

		public var iconColor: Color?
		public var iconStyle: HierarchicalShapeStyle
		public var iconVariants: SymbolVariants

		public init(headlineColor: Color? = nil,
					headlineStyle: HierarchicalShapeStyle = .primary,
					subheadlineColor: Color? = nil,
					subheadlineStyle: HierarchicalShapeStyle = .primary,
					iconColor: Color? = nil,
					iconStyle: HierarchicalShapeStyle = .primary,
					iconVariants: SymbolVariants = .none
		) {
			self.headlineColor = headlineColor
			self.headlineStyle = headlineStyle
			self.subheadlineColor = subheadlineColor
			self.subheadlineStyle = subheadlineStyle
			self.iconColor = iconColor
			self.iconStyle = iconStyle
			self.iconVariants = iconVariants
		}

		public static let `default` = Style(headlineStyle: .primary, subheadlineStyle: .secondary, iconStyle: .secondary, iconVariants: .fill)
	}
}

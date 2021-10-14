import Foundation
import SwiftUI

public extension Indicators {
	struct Indicator: Identifiable, Hashable {
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
		
		// MARK: Identifiable
		
		public static func == (lhs: Indicators.Indicator, rhs: Indicators.Indicator) -> Bool {
			lhs.id == rhs.id &&
			lhs.headline == rhs.headline &&
			lhs.subheadline == rhs.subheadline &&
			lhs.icon == rhs.icon
		}
		
		// MARK: - Hashable
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}

public extension Indicators.Indicator {
	enum DismissType {
		case manual
		case after(TimeInterval)
	}
	
	struct Style {
		public var headlineColor: Color?
		public var subheadlineColor: Color?
		public var iconColor: Color?
		
		public init(headlineColor: Color? = nil, subheadlineColor: Color? = nil, iconColor: Color? = nil) {
			self.headlineColor = headlineColor
			self.subheadlineColor = subheadlineColor
			self.iconColor = iconColor
		}
		
		public static let `default` = Style(headlineColor: .primary, subheadlineColor: .secondary, iconColor: .secondary)
	}
}

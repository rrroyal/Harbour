import SwiftUI
import Combine

@available(iOS 15.0, macOS 12.0, *)
public extension Toasts {
	class Toast: ObservableObject, Identifiable, Equatable {
		public init(
			id: String,
			dismissType: DismissType,
			icon: String?,
			title: String,
			description: String? = nil,
			style: Style = .primary,
			onTap: (() -> Void)? = nil
		) {
			self.id = id
			self.dismissType = dismissType
			self.icon = icon
			self.title = title
			self.description = description
			self.style = style
			self.onTap = onTap
		}
		
		public let id: String
		
		public let dismissType: DismissType

		public let icon: String?
		
		public let title: String
		public let description: String?
		
		public let style: Style
		
		public let onTap: (() -> Void)?
		
		@Published public var isExpanded: Bool = false {
			didSet { updateTimer() }
		}
		
		internal var dismiss: (() -> Void)!
		
		internal var timer: Timer? = nil
		
		public static func == (lhs: Toast, rhs: Toast) -> Bool {
			lhs.id == rhs.id
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
		
		internal func updateTimer() {
			guard case .after(let timeout) = self.dismissType, !isExpanded else {
				timer?.invalidate()
				return
			}
			
			timer?.invalidate()
			timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
				self?.dismiss()
			}
		}
	}
}

@available(iOS 15.0, macOS 12.0, *)
public extension Toasts.Toast {
	enum DismissType: Equatable {
		case none
		case manual
		case after(_ timeout: TimeInterval)
	}
	
	enum Style {
		case color(foreground: Color, background: Color)
		case material(_ material: Material)
		case colorAndMaterial(color: Color, material: Material)
		
		public static let primary: Self = .color(foreground: .primary, background: Color(uiColor: .tertiarySystemBackground))
	}
}

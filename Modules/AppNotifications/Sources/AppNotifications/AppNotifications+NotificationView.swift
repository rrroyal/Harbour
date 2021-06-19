//
//  AppNotifications+NotificationView.swift
//  AppNotifications
//
//  Created by royal on 13/06/2021.
//

import SwiftUI

// MARK: - AppNotifications+NotificationVIew

@available(iOS 15.0, macOS 12.0, *)
internal extension AppNotifications {
	struct NotificationView: View {
		@ObservedObject var notification: Notification
		let anchor: Edge
		let onHide: () -> Void
		let hideOffset: CGSize
		
		internal init(notification: Notification, anchor: Edge, containerGeometry: GeometryProxy, onHide: @escaping () -> Void) {
			self.notification = notification
			self.anchor = anchor
			self.onHide = onHide
			
			let hideOffsetMultiplier: Double = 0.25
			switch anchor {
				case .top:
					hideOffset = CGSize(width: 0, height: -(containerGeometry.size.height * hideOffsetMultiplier))
				case .leading:
					hideOffset = CGSize(width: -(containerGeometry.size.width * hideOffsetMultiplier), height: 0)
				case .bottom:
					hideOffset = CGSize(width: 0, height: (containerGeometry.size.height * hideOffsetMultiplier))
				case .trailing:
					hideOffset = CGSize(width: (containerGeometry.size.width * hideOffsetMultiplier), height: 0)
			}
		}
		
		@State private var translation: CGSize = .zero
		
		let cornerRadius: Double = 16
		let maxWidth: Double = 500
		let dragThreshold: Double = 20
		let dragMultiplier: Double = 0.075
		let animation: Animation = .interpolatingSpring(mass: 0.5, stiffness: 45, damping: 45, initialVelocity: 15)
		
		var offset: CGSize {
			let width: CGFloat
			let height: CGFloat
			if notification.dismissType == .none {
				width = translation.width * (dragMultiplier / 2)
				height = translation.height * (dragMultiplier / 2)
			} else {
				switch anchor {
					case .top:
						width = translation.width * (dragMultiplier / 2)
						height = translation.height * (translation.height < 0 ? 1 : dragMultiplier)
					case .leading:
						width = translation.width * (translation.width < 0 ? 1 : dragMultiplier)
						height = translation.height * (dragMultiplier / 2)
					case .trailing:
						width = translation.width * (translation.width > 0 ? 1 : dragMultiplier)
						height = translation.height * (dragMultiplier / 2)
					case .bottom:
						width = translation.width * (dragMultiplier / 2)
						height = translation.height * (translation.height > 0 ? 1 : dragMultiplier)
				}
			}
			
			return CGSize(width: width, height: height)
		}
		
		var notificationDragGesture: some Gesture {
			DragGesture()
				.onChanged { translation = $0.translation }
				.onEnded { drag in
					let shouldHide: Bool
					switch anchor {
						case .top: shouldHide = drag.translation.height < -dragThreshold
						case .leading: shouldHide = drag.translation.width < -dragThreshold
						case .trailing: shouldHide = drag.translation.width > dragThreshold
						case .bottom: shouldHide = drag.translation.height > dragThreshold
					}
					
					if shouldHide && notification.dismissType != .none {
						notification.isVisible = false
						onHide()
					}
					translation = CGSize.zero
				}
		}
		
		var backgroundShape: some InsettableShape {
			RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
		}
		
		@ViewBuilder
		var content: some View {
			HStack(spacing: 15) {
				if let icon = notification.icon {
					Image(systemName: icon)
						.font(.title2.weight(.semibold))
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(notification.title)
						.font(.headline)
					
					if let description = notification.description {
						Text(description)
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
				}
				.lineLimit(nil)
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.foregroundColor(notification.foregroundColor) // Foreground color
			.padding(.vertical, 12) // Vertical padding
			.padding(.horizontal, 18) // Horizontal padding
			.background(notification.backgroundStyle, in: backgroundShape) // Background
		}
		
		public var body: some View {
			Group {
				if notification.isVisible {
					content
						.mask(backgroundShape) // Shape mask
						.frame(maxWidth: maxWidth, alignment: .center) // Max width
						.offset(x: offset.width, y: offset.height) // Drag offset
						.gesture(notificationDragGesture) // Drag gesture
						.animation(animation) // Animation
						.transition(.asymmetric(insertion: .offset(hideOffset), removal: .offset(hideOffset))) // Transition
						.optionalTapGesture(notification.onTap)
				}
			}
		}
	}
}

// MARK: - View+

@available(iOS 15.0, macOS 12.0, *)
private extension View {
	@ViewBuilder
	func background<S: InsettableShape>(_ style: AppNotifications.Notification.BackgroundStyle, in shape: S) -> some View {
		switch style {
			case .material(let material):
				self.background(material, in: shape)
			case .color(let color):
				self
					.background(shape.fill(color))
					.background(Color(uiColor: .systemBackground))
			case .colorAndMaterial(let color, let material):
				self
					.background(material, in: shape)
					.background(shape.fill(color))
					.tint(color)
		}
	}
	
	@ViewBuilder
	func optionalTapGesture(_ action: (() -> Void)?) -> some View {
		if let action = action {
			self.onTapGesture(perform: action)
		} else {
			self
		}
	}
}

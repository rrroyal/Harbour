import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
internal extension AppNotifications {
	struct NotificationsOverlay: View {
		@ObservedObject var model: AppNotifications
		let alignment: Alignment
		let anchor: Edge
		
		@State var dragOffset: CGSize = .zero
		
		let dragInWrongDirectionMultiplier: CGFloat = 0.05
		let dragThreshold: CGFloat = 30
		let transition: AnyTransition = .asymmetric(insertion: .move(edge: .bottom), removal: .opacity)
		let animation: Animation = .interpolatingSpring(mass: 0.5, stiffness: 45, damping: 45, initialVelocity: 15)
		
		var dragGesture: some Gesture {
			DragGesture()
				.onChanged { drag in
					dragOffset.height = drag.translation.height > 0 ? drag.translation.height : drag.translation.height * dragInWrongDirectionMultiplier
					dragOffset.width = drag.translation.width * dragInWrongDirectionMultiplier
				}
				.onEnded { drag in
					dragOffset = .zero
					
					if drag.translation.height > dragThreshold {
						model.activeNotifications.first?.dismiss()
					}
				}
		}
		
		/* var offset: CGSize {
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
		} */
		
		var body: some View {
			ZStack {
				ForEach(model.activeNotifications.reversed()) { notification in
					let index = model.activeNotifications.firstIndex(of: notification) ?? 0
					let (scale, offset) = transformForIndex(index)
					
					NotificationView(notification: notification, anchor: anchor)
						.opacity(Double(scale))
						.zIndex(-Double(index))
						.gesture(index == 0 ? dragGesture : nil) // Frontmost drag gesture
						.offset(index == 0 ? dragOffset : .zero) // Frontmost drag gesture offset
						.scaleEffect(scale) // Z-scale
						.offset(x: 0, y: offset) // Z-offset
						.transition(transition)
				}
			}
			.padding()
			.frame(maxHeight: .infinity, alignment: .bottom)
			.animation(animation, value: model.activeNotifications)
			.transition(transition)
		}
		
		private func transformForIndex(_ index: Int) -> (scale: CGFloat, offset: CGFloat) {
			let scaleMultiplier: CGFloat = 0.1
			let offsetMultiplier: CGFloat = 10
			
			// 0: 1, 1: 0.9, 2: 0.8...
			let scale: CGFloat = 1 - (CGFloat(index) * scaleMultiplier)
			
			// 0: 0, 1: -10, 2: -20...
			let offset: CGFloat = -CGFloat(index) * offsetMultiplier
			
			if index == 0 {
				return (scale, offset)
			} else {
				// Not dragged: 0, dragged >= threshold: 1
				let dragStage = min(1, abs(dragOffset.height / dragThreshold))
				
				// Change values when dragging so it looks smoother
				let draggedScale = scale + (dragStage * scaleMultiplier)
				let draggedOffset = offset + (dragStage * offsetMultiplier)
				
				return (draggedScale, draggedOffset)
			}
		}
	}
}

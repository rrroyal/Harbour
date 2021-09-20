import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
internal extension Toasts {
	struct ToastsOverlay: View {
		@ObservedObject var model: Toasts
		
		@State var dragOffset: CGSize = .zero
		
		let dragInWrongDirectionMultiplier: CGFloat = 0.05
		let dragThreshold: CGFloat = 30
		let transition: AnyTransition = .asymmetric(insertion: .move(edge: .bottom), removal: .opacity)
		let animation: Animation = .interpolatingSpring(mass: 0.5, stiffness: 45, damping: 45, initialVelocity: 15)
		
		var dragGesture: some Gesture {
			DragGesture()
				.onChanged {
					let dismissType = model.activeToasts.first?.dismissType ?? .manual
					
					dragOffset.width = $0.translation.width * dragInWrongDirectionMultiplier
					if dismissType != .none {
						dragOffset.height = $0.translation.height > 0 ? $0.translation.height : $0.translation.height * dragInWrongDirectionMultiplier
					} else {
						dragOffset.height = $0.translation.height * dragInWrongDirectionMultiplier
					}
				}
				.onEnded {
					dragOffset = .zero
					
					guard let toast = model.activeToasts.first else { return }
					if toast.dismissType != .none && $0.translation.height > dragThreshold {
						toast.dismiss()
					}
				}
		}
		
		/* var dragOffset: CGSize {
			guard let toast = model.activeToasts.first else { return .zero }
			
			let width: CGFloat = translation.width * dragInWrongDirectionMultiplier
			let height: CGFloat
			if toast.dismissType == .none {
				height = translation.height * dragInWrongDirectionMultiplier
			} else {
				height = translation.height * (translation.height > 0 ? 1 : dragInWrongDirectionMultiplier)
			}
			
			return CGSize(width: width, height: height)
		}
		
		var dragGesture: some Gesture {
			DragGesture()
				.onChanged {
					print("😶‍🌫️", $0)
					translation = $0.translation
				}
				.onEnded {
					guard let toast = model.activeToasts.first else { return }

					if toast.dismissType != .none && $0.translation.height > dragThreshold {
						toast.dismiss()
					}
					
					translation = CGSize.zero
				}
		} */
		
		var body: some View {
			ZStack {
				ForEach(model.activeToasts.reversed()) { toast in
					let index = model.activeToasts.firstIndex(of: toast) ?? 0
					let (scale, offset) = transformForIndex(index)
					
					ToastView(toast: toast)
						.opacity(Double(scale))		// index-based opacity
						.zIndex(-Double(index))		// index-based z-index
						.offset(dragOffset) 		// Frontmost drag gesture offset
						.gesture(dragGesture) 		// Frontmost drag gesture
						.scaleEffect(scale) 		// Z-scale
						.offset(x: 0, y: offset) 	// Z-offset
						.transition(transition)
				}
			}
			.padding()
			.frame(maxHeight: .infinity, alignment: .bottom)
			.animation(animation, value: model.activeToasts)
			.animation(animation, value: dragOffset)
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

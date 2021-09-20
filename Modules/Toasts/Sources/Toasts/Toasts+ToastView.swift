import SwiftUI

// MARK: - Toasts+ToastView

// TODO: Scale down on press

@available(iOS 15.0, macOS 12.0, *)
internal extension Toasts {
	struct ToastView: View {
		@ObservedObject var toast: Toast
		
		let cornerRadius: Double = 16
		let maxWidth: Double = 500
		
		var backgroundShape: some InsettableShape {
			RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
		}
		
		var body: some View {
			HStack(spacing: 15) {
				if let icon = toast.icon {
					Image(systemName: icon)
						.font(.title2.weight(.semibold))
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(LocalizedStringKey(toast.title))
						.font(.headline)
					
					if let description = toast.description {
						Text(LocalizedStringKey(description))
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
				}
				.lineLimit(nil)
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			// .foregroundColor(toast.foregroundColor)				// Foreground color
			.padding(.vertical, 12)									// Vertical padding
			.padding(.horizontal, 18)								// Horizontal padding
			// .mask(backgroundShape)								// Shape mask
			.background(toast.style, in: backgroundShape)			// Background
			.frame(maxWidth: maxWidth, alignment: .center)			// Max width
			.optionalTapGesture(toast.onTap)
		}
	}
}

// MARK: - View+

@available(iOS 15.0, macOS 12.0, *)
private extension View {
	@ViewBuilder
	func background<S: InsettableShape>(_ style: Toasts.Toast.Style, in shape: S) -> some View {
		switch style {
			case .material(let material):
				background(material, in: shape)
			case .color(let foreground, let background):
				self
					.foregroundColor(foreground)
					.background(shape.fill(background))
					// .background(Color(uiColor: .systemBackground))
					.shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 6)
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
			onTapGesture(perform: action)
		} else {
			self
		}
	}
}

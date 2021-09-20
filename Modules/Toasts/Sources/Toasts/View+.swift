import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public extension View {
	/// Adds notification overlay.
	/// - Parameters:
	///   - model: `AppNotifications` model
	///   - alignment: Overlay alignment
	/// - Returns: View
	@ViewBuilder
	func toastsOverlay(model: Toasts) -> some View {
		overlay(Toasts.ToastsOverlay(model: model))
	}
}

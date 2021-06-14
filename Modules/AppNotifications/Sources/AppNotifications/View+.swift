//
//  View+.swift
//  AppNotifications
//
//  Created by royal on 13/06/2021.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public extension View {
	/// Adds notification overlay.
	/// - Parameters:
	///   - model: `AppNotifications` model
	///   - alignment: Overlay alignment
	///   - anchor: Overlay anchor
	/// - Returns: View
	@ViewBuilder
	func notificationsOverlay(_ model: AppNotifications, alignment: Alignment, anchor: Edge) -> some View {
		self.overlay(AppNotifications.NotificationsOverlay(model: model, alignment: alignment, anchor: anchor))
	}
}

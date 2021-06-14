//
//  AppNotifications+NotificationsOverlay.swift
//  AppNotifications
//
//  Created by royal on 13/06/2021.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
internal extension AppNotifications {
	struct NotificationsOverlay: View {
		@ObservedObject var model: AppNotifications
		let alignment: Alignment
		let anchor: Edge

		/* public init(model: AppNotifications, alignment: Alignment, anchor: Edge) {
		 	self.model = model
		 	self.alignment = alignment
		 	self.anchor = anchor
		 } */

		public var body: some View {
			ZStack(alignment: alignment) {
				ForEach(model.activeNotifications.reversed()) { notification in
					NotificationView(notification: notification, anchor: anchor, onHide: { model.dismiss(notification) })
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
			.padding()
		}
	}
}

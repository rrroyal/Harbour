//
//  AppNotifications+NotificationsOverlay.swift
//  AppNotifications
//
//  Created by unitears on 13/06/2021.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
internal extension AppNotifications {
	struct NotificationsOverlay: View {
		@ObservedObject var model: AppNotifications
		let alignment: Alignment
		let anchor: Edge

		/* public init(model: AppNotifications, alignment: Alignment, anchor: Edge) {
		 	model = model
		 	alignment = alignment
		 	anchor = anchor
		 } */

		public var body: some View {
			GeometryReader { geometry in
				ZStack(alignment: alignment) {
					ForEach(model.activeNotifications.reversed()) { notification in
						NotificationView(notification: notification, anchor: anchor, containerGeometry: geometry, onHide: { model.dismiss(notification) })
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
				.padding()
			}
		}
	}
}

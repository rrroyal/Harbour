import Combine
import Foundation

@available(iOS 15.0, macOS 12.0, *)
public class AppNotifications: ObservableObject {
	@Published internal private(set) var activeNotifications: [AppNotifications.Notification] = []
	
	public init() {}
	
	public func add(_ notification: AppNotifications.Notification) {
		notification.dismiss = {
			notification.timer?.cancel()
			notification.timer = nil
			self.dismiss(notification)
		}
		notification.updateTimer()
		activeNotifications.insert(notification, at: 0)
	}
	
	public func dismiss(_ notification: AppNotifications.Notification) {
		guard let index = activeNotifications.firstIndex(of: notification) else { return }
		activeNotifications.remove(at: index)
	}
	
	public func dismiss(matching notificationID: String) {
		guard let index = activeNotifications.firstIndex(where: { $0.id == notificationID }) else { return }
		activeNotifications.remove(at: index)
	}
}

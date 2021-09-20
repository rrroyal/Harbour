import Combine
import Foundation

@available(iOS 15.0, macOS 12.0, *)
public class Toasts: ObservableObject {
	@Published internal private(set) var activeToasts: [Toast] = []
	
	public init() {}
	
	public func add(_ toast: Toast) {
		toast.dismiss = { [weak self] in
			self?.dismiss(toast)
		}
		toast.updateTimer()
		activeToasts.insert(toast, at: 0)
	}
	
	public func dismiss(_ toast: Toast) {
		guard let index = activeToasts.firstIndex(of: toast) else { return }
		toast.timer?.invalidate()
		activeToasts.remove(at: index)
	}
	
	public func dismiss(matching id: String) {
		guard let index = activeToasts.firstIndex(where: { $0.id == id }) else { return }
		activeToasts[index].timer?.invalidate()
		activeToasts.remove(at: index)
	}
}

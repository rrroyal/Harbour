import Foundation

public class Indicators: ObservableObject {
	@Published public private(set) var activeIndicator: Indicator?
	
	internal var timer: Timer? = nil
	
	public init() { }
	
	public func display(_ indicator: Indicator) {
		if activeIndicator?.id != indicator.id {
			timer?.invalidate()
		}
		
		activeIndicator = indicator
		updateTimer()
	}
	
	public func dismiss() {
		activeIndicator = nil
		timer?.invalidate()
	}
	
	public func dismiss(matching id: String) {
		if activeIndicator?.id == id {
			dismiss()
		}
	}
	
	internal func updateTimer() {
		if case .after(let timeout) = activeIndicator?.dismissType {
			let storedIndicator = activeIndicator

			timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
				// Check if activeIndicator is still the same as it was previously
				if self?.activeIndicator == storedIndicator {
					self?.dismiss()
				}
			}
		}
	}
}

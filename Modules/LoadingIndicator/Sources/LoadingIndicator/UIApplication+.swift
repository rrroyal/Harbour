//
//  UIApplication+.swift
//  LoadingIndicator
//
//  Created by royal on 12/03/2021.
//	Based on https://github.com/futuretap/FTLinearActivityIndicator
//

import UIKit

@available(iOS 13, *)
public extension UIApplication {
	/// IndicatorWindow key
	private enum AssociatedKeys {
		static var indicatorWindowKey = "LoadingIndicator"
	}

	/// LoadingIndicator window
	private var indicatorWindow: UIWindow? {
		get { objc_getAssociatedObject(self, &AssociatedKeys.indicatorWindowKey) as? UIWindow }

		set {
			if let newValue = newValue {
				objc_setAssociatedObject(
					self,
					&AssociatedKeys.indicatorWindowKey,
					newValue as UIWindow?,
					.OBJC_ASSOCIATION_RETAIN_NONATOMIC
				)
			}
		}
	}

	/// Is loading indicator active?
	private(set) var isLoadingIndicatorActive: Bool? {
		get {
			guard let indicator = indicatorWindow?.subviews.first as? LoadingIndicatorView else { return nil }
			return indicator.animating
		}

		set {
			// swiftlint:disable indentation_width
			guard let indicator = indicatorWindow?.subviews.first as? LoadingIndicatorView,
			      let isActive = newValue else {
				return
			}

			if isActive {
				indicatorWindow?.isHidden = self.isStatusBarHidden
				indicator.isHidden = false
				indicator.alpha = 1
				indicator.startAnimating()
			} else {
				UIView.animate(withDuration: 0.5, animations: {
					indicator.alpha = 0
				}) { finished in
					if finished {
						indicator.isHidden = !self.isNetworkActivityIndicatorVisible
						self.indicatorWindow?.isHidden = !self.isNetworkActivityIndicatorVisible || self.isStatusBarHidden
						indicator.stopAnimating()
					}
				}
			}
		}
	}

	/// Helper function, updates the `self.isLoadingIndicatorActive` on the main thread.
	/// - Parameter isLoading: Is active?
	func setLoadingIndicator(isActive: Bool) {
		DispatchQueue.main.async {
			if isActive == self.isLoadingIndicatorActive {
				return
			}

			self.isLoadingIndicatorActive = isActive
		}
	}

	/// Adds a subview to the status bar witht the loading indicator.
	/// Top right corner if hasNotch, otherwise full width.
	func setupLoadingIndicator() {
		if self.indicatorWindow != nil {
			return
		}

		let hasNotch: Bool = UIDevice.current.userInterfaceIdiom == .phone && ((keyWindow ?? windows.first)?.safeAreaInsets.bottom ?? 0) > 0

		let statusBarFrame: CGRect = self.windows.first?.windowScene?.statusBarManager?.statusBarFrame ?? self.statusBarFrame
		indicatorWindow = UIWindow(frame: statusBarFrame)

		guard let indicatorWindow = indicatorWindow else {
			// It shouldn't ever execute, but that's better than fatalError
			return
		}

		let frame: CGRect
		if hasNotch {
			frame = CGRect(x: indicatorWindow.frame.width - 76, y: 6, width: 44, height: 4)
		} else {
			frame = CGRect(x: 0, y: indicatorWindow.bounds.height, width: indicatorWindow.bounds.width, height: 2)
		}

		indicatorWindow.windowLevel = UIWindow.Level.statusBar + 1

		let indicator = LoadingIndicatorView(frame: frame, hasNotch: hasNotch)
		indicator.isUserInteractionEnabled = false

		// indicator.startAnimating()
		indicatorWindow.addSubview(indicator)
		indicatorWindow.isHidden = false
		indicatorWindow.isUserInteractionEnabled = false

		UIApplication.shared.windows.first?.addSubview(indicatorWindow)
	}
}

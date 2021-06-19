//
//  UIWindow+.swift
//  Harbour
//
//  Created by royal on 19/06/2021.
//

import UIKit

extension UIWindow {
	open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			NotificationCenter.default.post(name: .DeviceDidShake, object: nil)
		}
	}
}

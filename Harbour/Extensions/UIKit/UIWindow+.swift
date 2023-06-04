//
//  UIWindow+.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import UIKit

extension UIWindow {
	override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		super.motionEnded(motion, with: event)

		switch motion {
		case .motionShake:
			NotificationCenter.default.post(name: .DeviceDidShake, object: nil)
		default:
			break
		}
	}
}

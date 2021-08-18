//
//  UIDevice+.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import AudioToolbox
import CoreHaptics
import UIKit

@available(iOS 14, *)
extension UIDevice {
	enum FeedbackStyle {
		case error, success, warning, light, medium, heavy, soft, rigid, selectionChanged
	}

	/// Generates a haptic feedback/vibration.
	/// - Parameter style: Style of the feedback
	func generateHaptic(_ style: FeedbackStyle) {
		guard UserDefaults.standard.bool(forKey: UserDefaults.Key.enableHaptics) else {
			return
		}

		let hapticCapability = CHHapticEngine.capabilitiesForHardware()
		let supportsHaptics = hapticCapability.supportsHaptics

		if supportsHaptics {
			// Haptic Feedback
			switch style {
				case .error:	UINotificationFeedbackGenerator().notificationOccurred(.error)
				case .success:	UINotificationFeedbackGenerator().notificationOccurred(.success)
				case .warning:	UINotificationFeedbackGenerator().notificationOccurred(.warning)
				case .light:	UIImpactFeedbackGenerator(style: .light).impactOccurred()
				case .medium:	UIImpactFeedbackGenerator(style: .medium).impactOccurred()
				case .heavy:	UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
				case .soft:		UIImpactFeedbackGenerator(style: .soft).impactOccurred()
				case .rigid:	UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
				case .selectionChanged: UISelectionFeedbackGenerator().selectionChanged()
			}
		} else {
			// Older devices
			switch style {
				case .error:	AudioServicesPlaySystemSound(1521)
				case .success:	break
				case .warning:	break
				case .light:	AudioServicesPlaySystemSound(1519)
				case .medium:	break
				case .heavy:	AudioServicesPlaySystemSound(1520)
				case .soft:		break
				case .rigid:	break
				case .selectionChanged: AudioServicesPlaySystemSound(1519)
			}
		}
	}
}

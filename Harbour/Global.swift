//
//  Global.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import UIKit
import CoreHaptics
import AudioToolbox

enum FeedbackStyle {
	case error
	case success
	case warning
	case light
	case medium
	case heavy
	case soft
	case rigid
	case selectionChanged
}

func generateHaptic(_ style: FeedbackStyle) {
	if (!UserDefaults.standard.bool(forKey: "hapticFeedback")) {
		return
	}
	
	let hapticCapability = CHHapticEngine.capabilitiesForHardware()
	let supportsHaptics = hapticCapability.supportsHaptics
		
	if (supportsHaptics) {
		// Haptic Feedback
		switch (style) {
		case .error:	UINotificationFeedbackGenerator().notificationOccurred(.error); break
		case .success:	UINotificationFeedbackGenerator().notificationOccurred(.success); break
		case .warning:	UINotificationFeedbackGenerator().notificationOccurred(.warning); break
		case .light:	UIImpactFeedbackGenerator(style: .light).impactOccurred(); break
		case .medium:	UIImpactFeedbackGenerator(style: .medium).impactOccurred(); break
		case .heavy:	UIImpactFeedbackGenerator(style: .heavy).impactOccurred(); break
		case .soft: 	UIImpactFeedbackGenerator(style: .soft).impactOccurred(); break
		case .rigid:	UIImpactFeedbackGenerator(style: .rigid).impactOccurred(); break
		case .selectionChanged:	UISelectionFeedbackGenerator().selectionChanged(); break
		}
	} else {
		// Older devices
		switch (style) {
		case .error:	AudioServicesPlaySystemSound(1521); break
		case .success:	break
		case .warning:	break
		case .light:	AudioServicesPlaySystemSound(1519); break
		case .medium:	break
		case .heavy:	AudioServicesPlaySystemSound(1520); break
		case .soft: 	break
		case .rigid:	break
		case .selectionChanged:	AudioServicesPlaySystemSound(1519); break
		}
	}
}

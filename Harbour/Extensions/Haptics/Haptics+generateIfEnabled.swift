//
//  Haptics+generateIfEnabled.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//

import CommonHaptics

extension Haptics {
	static func generateIfEnabled(_ style: HapticStyle) {
		guard Preferences.shared.enableHaptics else { return }
		generate(style)
	}
}

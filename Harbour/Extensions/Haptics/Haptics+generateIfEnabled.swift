//
//  Haptics+generateIfEnabled.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics

extension Haptics {
	@inlinable
	static func generateIfEnabled(_ style: HapticStyle) {
		guard Preferences.shared.enableHaptics else { return }
		generate(style)
	}
}

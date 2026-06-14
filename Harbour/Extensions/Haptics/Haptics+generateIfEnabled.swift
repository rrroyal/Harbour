//
//  Haptics+generateIfEnabled.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics

extension Haptics {
	nonisolated(unsafe) static var isHapticsEnabled: Bool = true

	static func generateIfEnabled(_ style: HapticStyle) {
		guard isHapticsEnabled else { return }
		Task { @MainActor in
			generate(style)
		}
	}
}

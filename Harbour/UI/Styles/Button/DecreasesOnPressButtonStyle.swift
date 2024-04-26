//
//  DecreasesOnPressButtonStyle.swift
//  Harbour
//
//  Created by royal on 26/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - DecreasesOnPressButtonStyle

struct DecreasesOnPressButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.modifier(ButtonScalesDownOnPressModifier(configuration: configuration))
	}
}

// MARK: - ButtonStyle+decreasesOnPress

extension ButtonStyle where Self == DecreasesOnPressButtonStyle {
	static var decreasesOnPress: Self { .init() }
}

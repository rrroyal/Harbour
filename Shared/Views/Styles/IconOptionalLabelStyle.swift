//
//  IconOptionalLabelStyle.swift
//  Harbour
//
//  Created by royal on 01/02/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - IconOptionalLabelStyle

struct IconOptionalLabelStyle: LabelStyle {
	let showIcon: Bool

	func makeBody(configuration: Configuration) -> some View {
		Label {
			configuration.title
		} icon: {
			if showIcon {
				configuration.icon
			}
		}
	}
}

// MARK: - LabelStyle+iconOptional

extension LabelStyle where Self == IconOptionalLabelStyle {
	static func iconOptional(showIcon: Bool) -> Self {
		IconOptionalLabelStyle(showIcon: showIcon)
	}
}

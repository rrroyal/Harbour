//
//  TwoLineLabeledContentStyle.swift
//  Harbour
//
//  Created by royal on 14/01/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

struct TwoLineLabeledContentStyle: LabeledContentStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading) {
			configuration.label
				.frame(maxWidth: .infinity, alignment: .leading)

			configuration.content
				.frame(maxWidth: .infinity, alignment: .leading)
				.multilineTextAlignment(.leading)
		}
	}
}

extension LabeledContentStyle where Self == TwoLineLabeledContentStyle {
	static var twoLine: Self { .init() }
}

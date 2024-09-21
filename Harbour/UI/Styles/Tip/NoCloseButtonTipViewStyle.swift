//
//  NoCloseButtonTipViewStyle.swift
//  Harbour
//
//  Created by royal on 18/09/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import TipKit

struct NoCloseButtonTipViewStyle: TipViewStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading) {
			HStack {
				configuration.image?
					.font(.callout)
					.fontWeight(.medium)

				configuration.title?
					.font(.callout)
					.fontWeight(.medium)
			}

			configuration.message?
				.font(.footnote)
				.fontWeight(.medium)
		}
		.foregroundStyle(.secondary)
		.multilineTextAlignment(.leading)
		.padding()
	}
}

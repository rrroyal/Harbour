//
//  HighlightedTextRenderer.swift
//  Harbour
//
//  Created by royal on 06/08/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

struct HighlightedTextRenderer: TextRenderer {
	var highlightedText: String

	func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
		for line in layout {
			for run in line {
				var bg = ctx

				print(run)

				bg.addFilter(.blur(radius: 2))

				bg.draw(run)
				ctx.draw(run)
			}
		}
	}
}

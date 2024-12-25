//
//  HighlightedText.swift
//  Harbour
//
//  Created by royal on 24/12/2024.
//  Copyright © 2024 shameful. All rights reserved.
//
//	https://alexanderweiss.dev/blog/2024-06-24-using-textrenderer-to-create-highlighted-text
//

import SwiftUI

// MARK: - HighlightedText

struct HighlightedText: View {
	var text: String

	var highlight: String?
	var highlightForegroundStyle = AnyShapeStyle(.accent)
	var highlightBackgroundStyle = AnyShapeStyle(.accent.opacity(Constants.secondaryOpacity))

	init(_ text: String) {
		self.text = text
	}

	var body: some View {
		if let highlight, !highlight.isEmpty {
			let text = highlightedTextComponents(from: highlight).reduce(Text(verbatim: "")) { result, component in
				result + component.text
			}

			text
				.textRenderer(HighlightTextRenderer(highlightBackgroundStyle: highlightBackgroundStyle))
		} else {
			Text(text)
		}
	}
}

// MARK: - HighlightedText+Modifiers

extension HighlightedText {
	func highlighting(_ string: String?) -> Self {
		var s = self
		s.highlight = string
		return s
	}

	func highlightForegroundStyle(_ style: any ShapeStyle) -> Self {
		var s = self
		s.highlightForegroundStyle = AnyShapeStyle(style)
		return s
	}

	func highlightBackgroundStyle(_ style: any ShapeStyle) -> Self {
		var s = self
		s.highlightBackgroundStyle = AnyShapeStyle(style)
		return s
	}
}

// MARK: - HighlightedText+Components

private extension HighlightedText {
	struct Component {
		let text: Text
		let range: Range<String.Index>
	}

	func highlightedTextComponents(from highlight: String) -> [Component] {
		let highlightRanges: [Component] = text
			.ranges(of: highlight, options: .caseInsensitive)
			.map {
				Component(
					text: Text(text[$0])
						.foregroundStyle(highlightForegroundStyle)
						.customAttribute(HighlightAttribute()),
					range: $0
				)
			}

		let remainingRanges = text
			.remainingRanges(from: highlightRanges.map(\.range))
			.map { Component(text: Text(text[$0]), range: $0) }

		return (highlightRanges + remainingRanges)
			.sorted { $0.range.lowerBound < $1.range.lowerBound }
	}
}

// MARK: - HighlightedText+HighlightTextRenderer

private extension HighlightedText {
	struct HighlightAttribute: TextAttribute { }

	struct HighlightTextRenderer: TextRenderer {
		var highlightBackgroundStyle: any ShapeStyle

		func draw(layout: Text.Layout, in context: inout GraphicsContext) {
			for run in layout.flatMap(\.self) {
				if run[HighlightAttribute.self] != nil {
					context.fill(
						Rectangle().path(in: run.typographicBounds.rect),
						with: .style(highlightBackgroundStyle)
					)
				}

				context.draw(run)
			}
		}
	}
}

// MARK: - String+ranges

private extension String {
	func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
		var ranges: [Range<Index>] = []
		while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
			ranges.append(range)
		}
		return ranges
	}

	func remainingRanges(from ranges: [Range<Index>]) -> [Range<Index>] {
		var result: [Range<Index>] = []

		// Sort the input ranges to process them in order
		let sortedRanges = ranges.sorted { $0.lowerBound < $1.lowerBound }

		// Start from the beginning of the string
		var currentIndex = self.startIndex

		for range in sortedRanges {
			if currentIndex < range.lowerBound {
				// Add the range from currentIndex to the start of the current range
				result.append(currentIndex..<range.lowerBound)
			}

			// Move currentIndex to the end of the current range
			currentIndex = range.upperBound
		}

		// If there's remaining text after the last range, add it as well
		if currentIndex < self.endIndex {
			result.append(currentIndex..<self.endIndex)
		}

		return result
	}
}

// MARK: - Previews

#Preview(traits: .sizeThatFitsLayout) {
	let highlight = "es"
	let highlightForegroundStyle = Color.white
	let highlightBackgroundStyle = Color.red

	VStack(alignment: .leading) {
		// swiftlint:disable line_length
		HighlightedText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
			.highlighting(highlight)
			.highlightForegroundStyle(highlightForegroundStyle)
			.highlightBackgroundStyle(highlightBackgroundStyle)
		HighlightedText("Curabitur pretium tincidunt lacus. Nulla gravida orci a odio, vitae semper sem. Suspendisse in justo eu magna luctus suscipit. Sed lectus. Praesent elementum hendrerit tortor. Sed semper lorem at felis. Vestibulum dapibus, mauris nec malesuada fames ac turpis velit, rhoncus id libero. Integer in mauris eu nibh euismod gravida.")
			.highlighting(highlight)
			.highlightForegroundStyle(highlightForegroundStyle)
			.highlightBackgroundStyle(highlightBackgroundStyle)
		HighlightedText("Phasellus iaculis neque purus, in dignissim leo fermentum a. Nulla facilisi. Sed mollis, libero non cursus fermentum, libero magna fermentum orci, in molestie neque eros ut ipsum. Nunc sit amet felis eget nunc lobortis mattis aliquam. Mauris in erat justo. Nullam euismod, nisi vel consectetur interdum, nisl nisi cursus nisi, nec dapibus eros magna eu libero. Aenean tincidunt, justo a fermentum tincidunt, arcu urna malesuada neque, ac aliquam libero risus a nisi.")
			.highlighting(highlight)
			.highlightForegroundStyle(highlightForegroundStyle)
			.highlightBackgroundStyle(highlightBackgroundStyle)
		// swiftlint:enable line_length
	}
	.multilineTextAlignment(.leading)
}

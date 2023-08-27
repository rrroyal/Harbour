//
//  ANSIParser.swift
//  Harbour
//
//  Created by royal on 27/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ANSIParser

enum ANSIParser {
	#if canImport(UIKit)
	typealias PlatformColor = UIColor
	typealias PlatformAttributes = AttributeScopes.UIKitAttributes
	#elseif canImport(AppKit)
	typealias PlatformColor = NSColor
	typealias PlatformAttributes = AttributeScopes.AppKitAttributes
	#endif

	static let escapeSequenceStart: [Character] = ["\u{001B}", "["]
	static let escapeSequenceEnd: Character = "m"
	static let escapeSequenceAllowedCharacters = "([0–9]|[:;<=>?!\"#$%&'()*+,-./ @A–Z[\\]^_`a–z{|}~])*"

	static func parse(_ string: String) -> AttributedString {
		var finalAttributedString = AttributedString()

		var escaped = false

		var buf = ""
		var modifiersBuf = ""
		var bufAttributes = AttributeContainer()

		for (index, char) in string.enumerated() {
			var collectBuf = false

			// Escape sequence is starting
			if char == Self.escapeSequenceStart[0],
			   let nextChar = string.nextCharacter(after: index),
			   nextChar == Self.escapeSequenceStart[1] {
				collectBuf = true
				escaped = true
			}

			if escaped {
				// Escaped, parse sequence
				if char == Self.escapeSequenceEnd {
					// End of the sequence, next character will be "readable"
					escaped = false

					let (shouldReset, attributes) = parseModifiers(modifiersBuf)
					modifiersBuf.removeAll()

					if shouldReset {
						bufAttributes = attributes
					} else {
						bufAttributes.merge(attributes, mergePolicy: .keepNew)
					}
				} else {
					// Content of ansi code (modifiers)
					modifiersBuf.append(char)
				}
			} else {
				// "Readable" character, add to buf
				buf.append(char)
			}

			if string.index(string.startIndex, offsetBy: index + 1) >= string.endIndex {
				// End of the string
				collectBuf = true
			}

			if collectBuf {
				// Parse buf and attributes
				let attributedString = AttributedString(buf, attributes: bufAttributes)
				finalAttributedString.append(attributedString)

				// Prepare buf for next round
				buf.removeAll()
			}
		}

		return finalAttributedString
	}

	static func trim(_ string: String) -> String {
		// I know this pattern doesn't cover all sequences, but it's good enough ¯\_(ツ)_/¯
		let regexPattern = "\(escapeSequenceStart[0])\\\(escapeSequenceStart[1])([0-9;])*\(escapeSequenceEnd)"
		guard let regex = try? Regex(regexPattern) else { return string }
		return string.replacing(regex, with: "")
	}

	private static func parseModifiers(_ modifiersStr: String) -> (reset: Bool, attributes: AttributeContainer) {
		let escapeCodes: [EscapeCode] = modifiersStr
			.dropFirst(2)
			.split(separator: ";")
			.compactMap {
				guard let code = Int($0) else { return nil }
				return EscapeCode(rawValue: code)
			}

		let attributes: [NSAttributedString.Key: Any] = escapeCodes
			.compactMap { $0.attributedStringAttributes }
			.reduce(into: [:]) { $0[$1.0] = $1.1 }

		let shouldReset = escapeCodes.contains(.reset)

		var container = AttributeContainer(attributes)

//		if escapeCodes.contains(.bold) {
//
//		}
//
//		if escapeCodes.contains(.faint) {
//
//		}
//
//		if escapeCodes.contains(.italic) {
//
//		}

		if escapeCodes.contains(.underline) {
			container[AttributeScopes.SwiftUIAttributes.UnderlineStyleAttribute.self] = .single
		}

		if escapeCodes.contains(.strikethrough) {
			container[AttributeScopes.SwiftUIAttributes.StrikethroughStyleAttribute.self] = .single
		}

		return (shouldReset, container)
	}
}

// MARK: - ANSIParser+EscapeCode

extension ANSIParser {
	enum EscapeCode: Int {
		case reset = 0
		case bold = 1
		case faint = 2
		case italic = 3
		case underline = 4
		case strikethrough = 9

		case fgBlack = 30
		case fgRed = 31
		case fgGreen = 32
		case fgYellow = 33
		case fgBlue = 34
		case fgMagenta = 35
		case fgCyan = 36
		case fgWhite = 37
		case fgBrightBlack = 90
		case fgBrightRed = 91
		case fgBrightGreen = 92
		case fgBrightYellow = 93
		case fgBrightBlue = 94
		case fgBrightMagenta = 95
		case fgBrightCyan = 96
		case fgBrightWhite = 97
		case bgBlack = 40
		case bgRed = 41
		case bgGreen = 42
		case bgYellow = 43
		case bgBlue = 44
		case bgMagenta = 45
		case bgCyan = 46
		case bgWhite = 47
		case bgBrightBlack = 100
		case bgBrightRed = 101
		case bgBrightGreen = 102
		case bgBrightYellow = 103
		case bgBrightBlue = 104
		case bgBrightMagenta = 105
		case bgBrightCyan = 106
		case bgBrightWhite = 107

		var attributedStringAttributes: (NSAttributedString.Key, Any)? {
			switch self {
			case .reset:
				nil
			case .bold:
				nil
			case .faint:
				nil
			case .italic:
				nil
			case .underline:
				(.underlineStyle, NSUnderlineStyle.single)
			case .strikethrough:
				(.strikethroughStyle, NSUnderlineStyle.single)
			case .fgBlack:
				(.foregroundColor, PlatformColor.black)
			case .fgRed:
				(.foregroundColor, PlatformColor.red)
			case .fgGreen:
				(.foregroundColor, PlatformColor.green)
			case .fgYellow:
				(.foregroundColor, PlatformColor.yellow)
			case .fgBlue:
				(.foregroundColor, PlatformColor.blue)
			case .fgMagenta:
				(.foregroundColor, PlatformColor.magenta)
			case .fgCyan:
				(.foregroundColor, PlatformColor.cyan)
			case .fgWhite:
				(.foregroundColor, PlatformColor.white)
			case .fgBrightBlack:
				(.foregroundColor, PlatformColor.black)
			case .fgBrightRed:
				(.foregroundColor, PlatformColor.red)
			case .fgBrightGreen:
				(.foregroundColor, PlatformColor.green)
			case .fgBrightYellow:
				(.foregroundColor, PlatformColor.yellow)
			case .fgBrightBlue:
				(.foregroundColor, PlatformColor.blue)
			case .fgBrightMagenta:
				(.foregroundColor, PlatformColor.magenta)
			case .fgBrightCyan:
				(.foregroundColor, PlatformColor.cyan)
			case .fgBrightWhite:
				(.foregroundColor, PlatformColor.white)
			case .bgBlack:
				(.backgroundColor, PlatformColor.black)
			case .bgRed:
				(.backgroundColor, PlatformColor.red)
			case .bgGreen:
				(.backgroundColor, PlatformColor.green)
			case .bgYellow:
				(.backgroundColor, PlatformColor.yellow)
			case .bgBlue:
				(.backgroundColor, PlatformColor.blue)
			case .bgMagenta:
				(.backgroundColor, PlatformColor.magenta)
			case .bgCyan:
				(.backgroundColor, PlatformColor.cyan)
			case .bgWhite:
				(.backgroundColor, PlatformColor.white)
			case .bgBrightBlack:
				(.backgroundColor, PlatformColor.black)
			case .bgBrightRed:
				(.backgroundColor, PlatformColor.red)
			case .bgBrightGreen:
				(.backgroundColor, PlatformColor.green)
			case .bgBrightYellow:
				(.backgroundColor, PlatformColor.yellow)
			case .bgBrightBlue:
				(.backgroundColor, PlatformColor.blue)
			case .bgBrightMagenta:
				(.backgroundColor, PlatformColor.magenta)
			case .bgBrightCyan:
				(.backgroundColor, PlatformColor.cyan)
			case .bgBrightWhite:
				(.backgroundColor, PlatformColor.white)
			}
		}
	}
}

// MARK: - String+nextCharacter

private extension String {
	func nextCharacter(after i: Int) -> Element? {
		let nextIndex = self.index(startIndex, offsetBy: i + 1)
		guard startIndex <= nextIndex, nextIndex < endIndex else { return nil }
		return self[nextIndex]
	}
}

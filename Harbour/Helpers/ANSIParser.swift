//
//  ANSIParser.swift
//  Harbour
//
//  Created by royal on 27/01/2023.
//

import SwiftUI
import UIKit

// TODO: Support splitting lines

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
				return nil
			case .bold:
				return nil
			case .faint:
				return nil
			case .italic:
				return nil
			case .underline:
				return (.underlineStyle, NSUnderlineStyle.single)
			case .strikethrough:
				return (.strikethroughStyle, NSUnderlineStyle.single)
			case .fgBlack:
				return (.foregroundColor, PlatformColor.black)
			case .fgRed:
				return (.foregroundColor, PlatformColor.red)
			case .fgGreen:
				return (.foregroundColor, PlatformColor.green)
			case .fgYellow:
				return (.foregroundColor, PlatformColor.yellow)
			case .fgBlue:
				return (.foregroundColor, PlatformColor.blue)
			case .fgMagenta:
				return (.foregroundColor, PlatformColor.magenta)
			case .fgCyan:
				return (.foregroundColor, PlatformColor.cyan)
			case .fgWhite:
				return (.foregroundColor, PlatformColor.white)
			case .fgBrightBlack:
				return (.foregroundColor, PlatformColor.black)
			case .fgBrightRed:
				return (.foregroundColor, PlatformColor.red)
			case .fgBrightGreen:
				return (.foregroundColor, PlatformColor.green)
			case .fgBrightYellow:
				return (.foregroundColor, PlatformColor.yellow)
			case .fgBrightBlue:
				return (.foregroundColor, PlatformColor.blue)
			case .fgBrightMagenta:
				return (.foregroundColor, PlatformColor.magenta)
			case .fgBrightCyan:
				return (.foregroundColor, PlatformColor.cyan)
			case .fgBrightWhite:
				return (.foregroundColor, PlatformColor.white)
			case .bgBlack:
				return (.backgroundColor, PlatformColor.black)
			case .bgRed:
				return (.backgroundColor, PlatformColor.red)
			case .bgGreen:
				return (.backgroundColor, PlatformColor.green)
			case .bgYellow:
				return (.backgroundColor, PlatformColor.yellow)
			case .bgBlue:
				return (.backgroundColor, PlatformColor.blue)
			case .bgMagenta:
				return (.backgroundColor, PlatformColor.magenta)
			case .bgCyan:
				return (.backgroundColor, PlatformColor.cyan)
			case .bgWhite:
				return (.backgroundColor, PlatformColor.white)
			case .bgBrightBlack:
				return (.backgroundColor, PlatformColor.black)
			case .bgBrightRed:
				return (.backgroundColor, PlatformColor.red)
			case .bgBrightGreen:
				return (.backgroundColor, PlatformColor.green)
			case .bgBrightYellow:
				return (.backgroundColor, PlatformColor.yellow)
			case .bgBrightBlue:
				return (.backgroundColor, PlatformColor.blue)
			case .bgBrightMagenta:
				return (.backgroundColor, PlatformColor.magenta)
			case .bgBrightCyan:
				return (.backgroundColor, PlatformColor.cyan)
			case .bgBrightWhite:
				return (.backgroundColor, PlatformColor.white)
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

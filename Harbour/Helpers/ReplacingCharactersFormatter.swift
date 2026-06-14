//
//  ReplacingCharactersFormatter.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import Foundation

final class ReplacingCharactersFormatter: Formatter {
	let occurence: String
	let replacement: String

	init(replacing occurence: String, with replacement: String) {
		self.occurence = occurence
		self.replacement = replacement
		super.init()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func string(for obj: Any?) -> String? {
		guard let string = obj as? String else { return nil }
		return string.replacingOccurrences(of: occurence, with: replacement)
	}

	override func editingString(for obj: Any) -> String? {
		guard let string = obj as? String else { return nil }
		return string.replacingOccurrences(of: occurence, with: replacement)
	}

	override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
		// this won't preserve attributes, but I guess this implementation isn't even needed?
		guard let attributedString = obj as? NSAttributedString else { return nil }
		let string = attributedString.string.replacingOccurrences(of: occurence, with: replacement)
		return NSAttributedString(string: string)
	}

	override func getObjectValue(
		_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
		for string: String,
		errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
	) -> Bool {
		obj?.pointee = string.replacingOccurrences(of: occurence, with: replacement) as AnyObject
		return true
	}
}

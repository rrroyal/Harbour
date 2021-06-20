//
//  MonospaceLabeled.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct MonospaceLabeled: View {
	let label: String
	let content: String?
	
	public init(label: String, content: String?) {
		self.label = label
		
		if let content = content, !content.isReallyEmpty {
			self.content = content
		} else {
			self.content = nil
		}
	}

	var body: some View {
		Labeled(label) {
			Text(content ?? "none")
				.font(.system(.subheadline, design: .monospaced))
				.foregroundColor(content != nil ? .primary : .secondary)
				.lineLimit(nil)
				.contentShape(Rectangle())
			#if os(macOS)
				.textSelection(.enabled)
			#else
				.onTapGesture { copy(content) }
			#endif
		}
	}

#if !os(macOS)
	func copy(_ object: Any?) {
		guard let object = object else { return }
		UIDevice.current.generateHaptic(.selectionChanged)
		UIPasteboard.general.string = String(describing: object)
	}
#endif
}

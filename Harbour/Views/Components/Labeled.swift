//
//  Labeled.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct Labeled: View {
	let label: String
	let content: String?
	let monospace: Bool
	let lineLimit: Int?
	let hideIfEmpty: Bool
	
	public init(label: String, content: String?, monospace: Bool = false, lineLimit: Int? = nil, hideIfEmpty: Bool = true) {
		self.label = label
		self.monospace = monospace
		self.lineLimit = lineLimit
		self.hideIfEmpty = hideIfEmpty
		
		if let content = content, !content.isEmpty {
			self.content = content
		} else {
			self.content = nil
		}
	}
	
	public init(label: String, bool: Bool?, hideIfEmpty: Bool = true) {
		self.label = label
		self.monospace = false
		self.lineLimit = 1
		self.hideIfEmpty = hideIfEmpty
		
		if let bool = bool {
			content = bool ? "✅" : "❌"
		} else {
			content = nil
		}
	}

	var body: some View {
		if (hideIfEmpty && !(content?.isReallyEmpty ?? true)) || !hideIfEmpty {
			HStack {
				Text(label)
					.font(.body)
				
				Spacer()
				
				Text(content ?? "none")
					.font(.system(.body, design: monospace ? .monospaced : .default))
					.foregroundColor(content != nil ? .primary : .secondary)
					.lineLimit(lineLimit)
					.multilineTextAlignment(.trailing)
					.textSelection(.enabled)
			}
		}
	}
}

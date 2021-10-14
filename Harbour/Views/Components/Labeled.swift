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
	
	public init(label: String, content: String?, monospace: Bool = false, lineLimit: Int? = nil) {
		self.label = label
		self.monospace = monospace
		self.lineLimit = lineLimit
		
		if let content = content, !content.isEmpty {
			self.content = content
		} else {
			self.content = nil
		}
	}
	
	public init(label: String, bool: Bool?) {
		self.label = label
		self.monospace = false
		self.lineLimit = 1
		
		if let bool = bool {
			content = bool ? "✅" : "❌"
		} else {
			content = "❔"
		}
	}

	var body: some View {
		HStack {
			Text(LocalizedStringKey(label))
			
			Spacer()
			
			Text(content ?? "none")
				.font(.system(.subheadline, design: monospace ? .monospaced : .default))
				.foregroundColor(content != nil ? .primary : .secondary)
				.lineLimit(lineLimit)
				.multilineTextAlignment(.trailing)
		}
	}
}

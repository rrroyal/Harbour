//
//  CustomSection.swift
//  Harbour
//
//  Created by royal on 20/06/2021.
//

import SwiftUI

struct LabeledSection: View {
	let label: String
	let content: String?
	let monospace: Bool
	
	public init(label: String, content: String?, monospace: Bool = false) {
		self.label = label
		self.monospace = monospace
		
		if let content = content, !content.isReallyEmpty {
			self.content = content
		} else {
			self.content = nil
		}
	}
	
	var body: some View {
		CustomSection(label: label) {
			Text(content ?? "none")
				.font(.system(.callout, design: monospace ? .monospaced : .default))
				.foregroundColor(content != nil ? .primary : .secondary)
				.lineLimit(nil)
				.contentShape(Rectangle())
				.textSelection(.enabled)
		}
	}
}

struct LabeledSection_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			LabeledSection(label: "Headline", content: "Content", monospace: true)
			LabeledSection(label: "Headline", content: nil, monospace: false)
		}
		.previewLayout(.sizeThatFits)
		.padding()
    }
}

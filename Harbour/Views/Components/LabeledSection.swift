//
//  LabeledSection.swift
//  Harbour
//
//  Created by royal on 20/06/2021.
//

/* yeah, i'm sorry */

import SwiftUI

struct LabeledSection: View {
	let label: String
	let content: String?
	let monospace: Bool
	
	public init(label: String, content: String?, monospace: Bool = true) {
		self.label = label
		self.monospace = monospace
		
		if let content = content, !content.isReallyEmpty {
			self.content = content
		} else {
			self.content = nil
		}
	}
	
	let backgroundColor: Color = Color(uiColor: UIColor.secondarySystemGroupedBackground)
	
    var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(LocalizedStringKey(label))
				.font(.footnote)
				.foregroundStyle(.secondary)
				.textCase(.uppercase)
				.padding(.horizontal)
			
			Text(content ?? "none")
				.font(.system(.callout, design: monospace ? .monospaced : .default))
				.foregroundColor(content != nil ? .primary : .secondary)
				.lineLimit(nil)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.medium)
				.background(
					RoundedRectangle(cornerRadius: Globals.Views.cornerRadius, style: .continuous)
						.fill(backgroundColor)
				)
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

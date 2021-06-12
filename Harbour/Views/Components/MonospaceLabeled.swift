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
	
	var body: some View {
		Labeled(label) {
			Text(content ?? "none")
				.font(.system(.subheadline, design: .monospaced))
				.foregroundColor(content != nil ? .primary : nil)
				.lineLimit(nil)
				.contentShape(Rectangle())
				.onLongPressGesture { copy(content) }
		}
	}
	
	func copy(_ object: Any?) {
		guard let object = object else { return }
		UIDevice.current.generateHaptic(.selectionChanged)
		UIPasteboard.general.string = String(describing: object)
	}
	}

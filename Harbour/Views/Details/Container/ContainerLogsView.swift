//
//  ContainerLogsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI
import PortainerKit

struct ContainerLogsView: View {
	let container: PortainerKit.Container
	
	let entries: [String] = .init(repeating: "ahh", count: 50)
	
    var body: some View {
		List {
			ForEach(entries, id: \.self) { entry in
				Text(entry)
					.font(.system(.callout, design: .monospaced))
					.lineLimit(nil)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
					.contentShape(Rectangle())
					.onTapGesture {
						UIDevice.current.generateHaptic(.selectionChanged)
						UIPasteboard.general.string = entry
					}
				}
		}
		.listStyle(.plain)
		.navigationTitle(Text("Logs"))
		.navigationBarTitleDisplayMode(.inline)
    }
}

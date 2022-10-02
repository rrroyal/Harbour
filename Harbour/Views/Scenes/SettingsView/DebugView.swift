//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import SwiftUI

// MARK: - DebugView

struct DebugView: View {
	var body: some View {
		List {
			#if DEBUG
			LastBackgroundRefreshSection()
			#endif
		}
		.navigationTitle(Localizable.Debug.title)
	}
}

// MARK: - DebugView+Components

private extension DebugView {
	#if DEBUG
	struct LastBackgroundRefreshSection: View {
		var body: some View {
			Section(content: {
				if let lastBackgroundRefreshDate = Preferences.shared.lastBackgroundRefreshDate {
					Text(Date(timeIntervalSince1970: lastBackgroundRefreshDate), format: .dateTime)
				} else {
					Text("Never")
						.foregroundStyle(.secondary)
				}
			}, header: {
				Text("Last background refresh")
			})
		}
	}
	#endif
}

// MARK: - Previews

struct DebugView_Previews: PreviewProvider {
	static var previews: some View {
		DebugView()
	}
}

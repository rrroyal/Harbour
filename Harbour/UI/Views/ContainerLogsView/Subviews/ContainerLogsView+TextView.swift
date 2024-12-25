//
//  ContainerLogsView+TextView.swift
//  Harbour
//
//  Created by royal on 17/11/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension ContainerLogsView {
	struct TextView: View {
		var logs: [String]
		var scrollProxy: ScrollViewProxy
		var searchText: String

		var body: some View {
			LazyVStack(alignment: .leading, spacing: 0) {
				ForEach(Array(logs.enumerated()), id: \.0) { _, line in
					HighlightedText(line)
						.highlighting(searchText)
//						.textSelection(.enabled)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				}
			}
#if os(iOS)
			.padding(.horizontal, 10)
#elseif os(macOS)
			.padding(.horizontal)
#endif
			.id(ContainerLogsView.ViewID.logsLabel)
		}
	}
}

// MARK: - Previews

#Preview {
	ScrollViewReader { proxy in
		ScrollView {
			ContainerLogsView.TextView(
				logs: ContainerLogsView.PreviewContext.logs.split(separator: "\n").map(String.init),
				scrollProxy: proxy,
				searchText: "lsio"
			)
		}
	}
}

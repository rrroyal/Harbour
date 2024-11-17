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
		var logs: String?
		var scrollProxy: ScrollViewProxy

		var body: some View {
			LazyVStack {
				Text(logs ?? "")
					.font(ContainerLogsView.normalFont)
					.textSelection(.enabled)
//					.textRenderer(HighlightedTextRenderer(highlightedText: ""))
#if os(iOS)
					.padding(.horizontal, 10)
#elseif os(macOS)
					.padding(.horizontal)
#endif
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
					.id(ContainerLogsView.ViewID.logsLabel)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ScrollViewReader { proxy in
		ScrollView {
			ContainerLogsView.TextView(
				logs: ContainerLogsView.PreviewContext.logs,
				scrollProxy: proxy
			)
		}
	}
}

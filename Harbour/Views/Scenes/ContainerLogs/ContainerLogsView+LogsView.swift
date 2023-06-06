//
//  ContainerLogsView+LogsView.swift
//  Harbour
//
//  Created by royal on 27/01/2023.
//

import SwiftUI
import CommonHaptics

// MARK: - ContainerLogsView+LogsView

extension ContainerLogsView {
	struct LogsView: View {
		static let labelID = "LogsLabel"

		let logs: AttributedString

		var body: some View {
			LazyVStack {
				Text(logs)
					.font(.caption)
					.fontDesign(.monospaced)
					.textSelection(.enabled)
					.padding(.horizontal, 10)
					.padding(.bottom, 10)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
					.id(Self.labelID)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerLogsView.LogsView(logs: "hello word")
}

//
//  ContainerLogsView+PlaceholderView.swift
//  Harbour
//
//  Created by royal on 21/01/2023.
//

import SwiftUI

// MARK: - ContainerLogsView+PlaceholderView

extension ContainerLogsView {
	struct PlaceholderView: View {
		let viewState: ViewModel.ViewState

		var body: some View {
			Group {
				switch viewState {
					case .loading:
						ProgressView()
							.progressViewStyle(.circular)
					case .hasLogs:
						EmptyView()
					default:
						if let title = viewState.title {
							Text(title)
						}
				}
			}
			.foregroundStyle(.secondary)
			.transition(.opacity)
			.animation(.easeInOut, value: viewState)
		}
	}
}

// MARK: - Previews

struct ContainerLogsView_PlaceholderView_Previews: PreviewProvider {
	static var previews: some View {
		ContainerLogsView.PlaceholderView(viewState: .loading)
		ContainerLogsView.PlaceholderView(viewState: .hasLogs)
		ContainerLogsView.PlaceholderView(viewState: .logsEmpty)
		ContainerLogsView.PlaceholderView(viewState: .error(NSError(domain: "", code: 0, userInfo: nil)))
	}
}

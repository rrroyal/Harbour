//
//  ContentView+PlaceholderView.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import SwiftUI

// MARK: - ContentView+PlaceholderView

extension ContentView {
	struct PlaceholderView: View {
		let viewState: ViewModel.ViewState

		var body: some View {
			Group {
				switch viewState {
				case .loading:
					ProgressView()
						.progressViewStyle(.circular)
				case .hasContainers:
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

#Preview("loading") {
	ContentView.PlaceholderView(viewState: .loading)
}

#Preview("error") {
	ContentView.PlaceholderView(viewState: .error(NSError(domain: "", code: 0, userInfo: nil)))
}

#Preview("hasContainers") {
	ContentView.PlaceholderView(viewState: .hasContainers)
}

#Preview("containersEmpty") {
	ContentView.PlaceholderView(viewState: .containersEmpty)
}

#Preview("noEndpointSelected") {
	ContentView.PlaceholderView(viewState: .noEndpointSelected)
}

#Preview("noEndpoints") {
	ContentView.PlaceholderView(viewState: .noEndpoints)
}

#Preview("noServer") {
	ContentView.PlaceholderView(viewState: .noServer)
}

#Preview("somethingWentWrong") {
	ContentView.PlaceholderView(viewState: .somethingWentWrong)
}

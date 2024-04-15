//
//  StackDetailsView+DownloadStackFileView.swift
//  Harbour
//
//  Created by royal on 14/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

// MARK: - StackDetailsView+DownloadStackFileView

extension StackDetailsView {
	struct DownloadStackFileView: View {
		@Environment(StackDetailsView.ViewModel.self) private var viewModel
		@Environment(\.dismiss) private var dismiss
		var stackID: String

		@State private var showError = false

		@ViewBuilder @MainActor
		private var downloadButton: some View {
			Button {
				downloadStackFile()
			} label: {
				switch viewModel.stackFileViewState {
				case .loading, .reloading:
					ProgressView()
						.padding(.vertical, 2)
				case .success:
					EmptyView()
				case .failure(let error):
					Group {
						if showError {
							Text(error.localizedDescription)
								.padding(.vertical, 1)
						} else {
							Label("Generic.Download", systemImage: SFSymbol.download)
						}
					}
					.onAppear {
						showError = true
						Task {
							try? await Task.sleep(for: .seconds(3))
							showError = false
						}
					}
				}
			}
			.disabled(viewModel.stackFileViewState.isLoading)
		}

		var body: some View {
			VStack {
				Group {
					if let stackFileContents = viewModel.stackFileViewState.value {
						ShareLink(item: stackFileContents)
					} else {
						downloadButton
					}
				}
				.buttonStyle(.customPrimary)
				.accentColor(showError ? .red : Color.accent)
				.id("MainButton")
			}
			.padding()
			.animation(.easeInOut, value: viewModel.stackFileViewState)
			.animation(.easeInOut, value: showError)
			.task { try? await viewModel.getStackFile().value }
		}
	}
}

// MARK: - StackDetailsView.DownloadStackFileView+Actions

private extension StackDetailsView.DownloadStackFileView {
	@MainActor
	func downloadStackFile() {
		showError = false
		Haptics.generateIfEnabled(.light)
		viewModel.getStackFile()
	}
}

// MARK: - Previews

#Preview {
	StackDetailsView.DownloadStackFileView(stackID: "")
}

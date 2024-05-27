//
//  CreateStackView+StackFileContentsView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI
import UniformTypeIdentifiers

// MARK: - CreateStackView+StackFileContentsView

extension CreateStackView {
	struct StackFileContentsView: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel
		@Environment(\.errorHandler) private var errorHandler
		var allowedContentTypes: [UTType]
		var onStackFileSelection: ((String?) -> Void)?

		var body: some View {
			@Bindable var viewModel = viewModel

			NormalizedSection {
				VStack {
					if let stackFileContents = viewModel.stackFileContent {
						ViewForFileContent(stackFileContent: stackFileContent)
					} else if viewModel.isLoadingStackFileContents {
						ViewForLoadingContent()
					} else {
						ViewForSelectFile()
					}
				}
				.frame(maxWidth: .infinity)
				.id("StackFileContent")
			} header: {
				Text("CreateStackView.StackFileContents")
			}
			.listRowInsets(.zero)
			.animation(.smooth, value: viewModel.isStackFileContentsTargeted)
			.onDrop(of: allowedContentTypes, isTargeted: $viewModel.isStackFileContentsTargeted) { items in
				Haptics.generateIfEnabled(.selectionChanged)
				return onItemsDrop(items)
			}
		}
	}
}

// MARK: - CreateStackView.StackFileContentsView+Actions

private extension CreateStackView.StackFileContentsView {
	func onItemsDrop(_ items: [NSItemProvider]) -> Bool {
		let item = items.first { $0.hasItemConformingToTypeIdentifier(UTType.yaml.identifier) }
		guard let item else { return false }

		Task {
			do {
				guard let url = try await item.loadItem(forTypeIdentifier: UTType.yaml.identifier) as? URL else { return }

				#if os(iOS)
				let securityScopedResource = true
				#elseif os(macOS)
				let securityScopedResource = false
				#endif
				let stackFileContent = try viewModel.loadStackFile(at: url, securityScopedResource: securityScopedResource)
				onStackFileSelection?(stackFileContent)
			} catch {
				errorHandler(error)
			}
		}

		return true
	}
}

// MARK: - CreateStackView.StackFileContentsView+ViewForFileContent

private extension CreateStackView.StackFileContentsView {
	struct ViewForFileContent: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel
		var stackFileContent: String

		var body: some View {
			Text(stackFileContent.trimmingCharacters(in: .whitespacesAndNewlines))
				.foregroundStyle(.primary)
				.font(.caption)
				.fontDesign(.monospaced)
				.lineLimit(viewModel.showWholeStackFileContents ? nil : 12)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				#if os(iOS)
				.padding(.horizontal)
				.padding(.vertical, 10)
				#elseif os(macOS)
				.padding(.horizontal, 4)
				#endif
				.contextMenu {
					Group {
						Button {
							Haptics.generateIfEnabled(.light)
							viewModel.showWholeStackFileContents.toggle()
						} label: {
							Label(
								viewModel.showWholeStackFileContents ? "Generic.Collapse" : "Generic.Expand",
								systemImage: viewModel.showWholeStackFileContents ? SFSymbol.collapse : SFSymbol.expand
							)
						}

						Divider()

						ShareLink(item: stackFileContent)

						Divider()

						Button(role: .destructive) {
							Haptics.generateIfEnabled(.light)
							viewModel.stackFileContent = nil
						} label: {
							Label("Generic.Clear", systemImage: SFSymbol.remove)
						}
					}
					.labelStyle(.titleAndIcon)
				}
		}
	}
}

// MARK: - CreateStackView.StackFileContentsView+ViewForLoadingContent

private extension CreateStackView.StackFileContentsView {
	struct ViewForLoadingContent: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel

		var body: some View {
			ProgressView()
				#if os(macOS)
				.controlSize(.small)
				#endif
				.contextMenu {
					Button {
						Haptics.generateIfEnabled(.light)
						viewModel.fetchStackFileContentsTask?.cancel()
					} label: {
						Label("Generic.Cancel", systemImage: SFSymbol.cancel)
					}
					.labelStyle(.titleAndIcon)
				}
		}
	}
}

// MARK: - CreateStackView.StackFileContentsView+ViewForSelectFile

private extension CreateStackView.StackFileContentsView {
	struct ViewForSelectFile: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel

		var body: some View {
			Button {
				Haptics.generateIfEnabled(.sheetPresentation)
				viewModel.isFileImporterPresented = true
			} label: {
				Text("CreateStackView.SelectStackFile")
					#if os(macOS)
					.frame(maxWidth: .infinity)
					.contentShape(Rectangle())
					#endif
			}
			#if os(macOS)
			.foregroundStyle(.accent)
			.buttonStyle(.plain)
			#endif
		}
	}
}

// MARK: - Previews

#Preview("Empty") {
	CreateStackView.StackFileContentsView(
		allowedContentTypes: []
	)
	.environment(CreateStackView.ViewModel())
}

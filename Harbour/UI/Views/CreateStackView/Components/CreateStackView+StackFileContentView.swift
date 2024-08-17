//
//  CreateStackView+StackFileContentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI
import UniformTypeIdentifiers

// MARK: - CreateStackView+StackFileContentView

extension CreateStackView {
	struct StackFileContentView: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel
		@Environment(\.errorHandler) private var errorHandler
		var allowedContentTypes: [UTType]
		var onStackFileSelection: ((String?) -> Void)?

		var body: some View {
			@Bindable var viewModel = viewModel

			NormalizedSection {
				Group {
					if let stackFileContent = viewModel.stackFileContent {
						ViewForFileContent(stackFileContent: stackFileContent)
							.listRowInsets(.zero)
					} else if viewModel.isLoadingStackFileContent {
						ViewForLoadingContent()
					} else {
						ViewForEmpty()
					}
				}
				.transition(.opacity)
				.frame(maxWidth: .infinity)
			} header: {
				Text("CreateStackView.StackFileContent")
			}
			.animation(.default, value: viewModel.stackFileContent)
			.animation(.default, value: viewModel.isLoadingStackFileContent)
			.animation(.default, value: viewModel.isStackFileContentTargeted)
			.onDrop(of: allowedContentTypes, isTargeted: $viewModel.isStackFileContentTargeted) { items in
				Haptics.generateIfEnabled(.selectionChanged)
				return onItemsDrop(items)
			}
			.id("\(Self.self).\(viewModel.stackFileContent?.hashValue ?? 0).\(viewModel.isLoadingStackFileContent)")
		}
	}
}

// MARK: - CreateStackView.StackFileContentView+Actions

private extension CreateStackView.StackFileContentView {
	func onItemsDrop(_ items: [NSItemProvider]) -> Bool {
		let item = items.first { $0.hasItemConformingToTypeIdentifier(UTType.yaml.identifier) }
		guard let item else { return false }

		_ = item.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.yaml.identifier) { url, _, error in
			Task { @MainActor in
				do {
					if let error {
						throw error
					}

					guard let url else {
						throw CreateStackView.ViewModel.Error.unableToAccessFile
					}

					#if os(iOS)
					let securityScopedResource = true
					#elseif os(macOS)
					let securityScopedResource = false
					#endif
					try viewModel.loadStackFile(at: url, securityScopedResource: securityScopedResource)
				} catch {
					errorHandler(error)
				}
			}
		}

		return true
	}
}

// MARK: - CreateStackView.StackFileContentView+Subviews

private extension CreateStackView.StackFileContentView {
	struct ViewForFileContent: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel
		var stackFileContent: String

		var body: some View {
			Button {
				Haptics.generateIfEnabled(.sheetPresentation)
				viewModel.isTextEditorSheetPresented = true
			} label: {
				Text(stackFileContent.trimmingCharacters(in: .whitespacesAndNewlines))
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
					.contentShape(Rectangle())
			}
			.foregroundStyle(.primary)
			.font(.caption)
			.fontDesign(.monospaced)
			.lineLimit(12)
			#if os(iOS)
			.padding(.horizontal)
			.padding(.vertical, 10)
			#elseif os(macOS)
			.padding(.horizontal, 4)
			.buttonStyle(.plain)
			#endif
			.contextMenu {
				Group {
					Button {
						Haptics.generateIfEnabled(.sheetPresentation)
						viewModel.isTextEditorSheetPresented = true
					} label: {
						Label("Generic.Edit", systemImage: SFSymbol.edit)
					}

					PasteButton(payloadType: String.self) { strings in
						if let string = strings.first {
							Haptics.generateIfEnabled(.selectionChanged)
							viewModel.stackFileContent = string
						}
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
						viewModel.fetchStackFileContentTask?.cancel()
					} label: {
						Label("Generic.Cancel", systemImage: SFSymbol.cancel)
					}
					.labelStyle(.titleAndIcon)
				}
		}
	}

	struct ViewForEmpty: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel

		var body: some View {
			Group {
				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					viewModel.isTextEditorSheetPresented = true
				} label: {
					Label("CreateStackView.Edit", systemImage: SFSymbol.edit)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
				}
				.contextMenu {
					Group {
						PasteButton(payloadType: String.self) { strings in
							if let string = strings.first {
								Haptics.generateIfEnabled(.selectionChanged)
								viewModel.stackFileContent = string
							}
						}
					}
					.labelStyle(.titleAndIcon)
				}

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					viewModel.isFileImportSheetPresented = true
				} label: {
					Label("CreateStackView.SelectFile", systemImage: "folder")
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
				}
			}
			#if os(macOS)
			.foregroundStyle(.accent)
			.buttonStyle(.plain)
			#endif
		}
	}
}

// MARK: - Previews

#Preview {
	Form {
		CreateStackView.StackFileContentView(
			allowedContentTypes: []
		)
	}
	.environment(CreateStackView.ViewModel())
}

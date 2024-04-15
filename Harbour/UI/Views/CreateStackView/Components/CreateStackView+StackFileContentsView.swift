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
		@Binding var stackFileContent: String?
		@Binding var isFileImporterPresented: Bool
		@Binding var isStackFileContentsTargeted: Bool
		var allowedContentTypes: [UTType]
		var handleStackFileDrop: ([NSItemProvider]) -> Bool

		var body: some View {
			NormalizedSection {
				VStack {
					if let stackFileContent {
						Text(stackFileContent)
							.foregroundStyle(.primary)
							.font(.caption)
							.fontDesign(.monospaced)
							.lineLimit(12)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
							.padding(.horizontal)
							.padding(.vertical, 10)
							.contextMenu {
								Button {
									Haptics.generateIfEnabled(.selectionChanged)
									self.stackFileContent = nil
								} label: {
									Label("Generic.Clear", systemImage: SFSymbol.remove)
								}
							}
					} else {
						Button("CreateStackView.SelectStackFile") {
							Haptics.generateIfEnabled(.sheetPresentation)
							isFileImporterPresented = true
						}
					}
				}
				.frame(maxWidth: .infinity)
				.background(isStackFileContentsTargeted ? Color.tertiaryBackground : nil)
			} header: {
				Text("CreateStackView.StackFileContents")
			}
			.listRowInsets(.zero)
			.transition(.opacity)
			.animation(.easeInOut, value: isStackFileContentsTargeted)
			.onDrop(of: allowedContentTypes, isTargeted: $isStackFileContentsTargeted) { items in
				handleStackFileDrop(items)
			}
		}
	}
}

// MARK: - Previews

#Preview("Empty") {
	CreateStackView.StackFileContentsView(
		stackFileContent: .constant(nil),
		isFileImporterPresented: .constant(false),
		isStackFileContentsTargeted: .constant(false),
		allowedContentTypes: [],
		handleStackFileDrop: { _ in false }
	)
}

#Preview("With Content") {
	CreateStackView.StackFileContentsView(
		stackFileContent: .constant("yaml"),
		isFileImporterPresented: .constant(false),
		isStackFileContentsTargeted: .constant(false),
		allowedContentTypes: [],
		handleStackFileDrop: { _ in false }
	)
}

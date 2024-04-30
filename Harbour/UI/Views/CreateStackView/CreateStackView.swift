//
//  CreateStackView.swift
//  Harbour
//
//  Created by royal on 14/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - CreateStackView

struct CreateStackView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel = ViewModel()

	var onStackFileSelection: ((String?) -> Void)?
	var onStackCreation: ((Stack) -> Void)?

	private let allowedContentTypes: [UTType] = [
		.yaml,
		.text
	]

	private var navigationTitle: String {
		viewModel.stackName.isReallyEmpty ? String(localized: "CreateStackView.Title") : viewModel.stackName
	}

	@ViewBuilder @MainActor
	private var createButton: some View {
		Button {
			createStack()
		} label: {
			if viewModel.isLoading {
				ProgressView()
					#if os(macOS)
					.controlSize(.small)
					#endif
			} else {
				Label("CreateStackView.Create", systemImage: SFSymbol.plus)
			}
		}
		.keyboardShortcut(.defaultAction)
		.transition(.opacity)
		.disabled(!viewModel.canCreateStack)
		.disabled(viewModel.isLoading)
	}

	var body: some View {
		Form {
			NormalizedSection {
				TextField("CreateStackView.Name", text: $viewModel.stackName)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
					.labelsHidden()
					.submitLabel(viewModel.canCreateStack ? .send : .continue)
					.onSubmit(createStack)
			} header: {
				Text("CreateStackView.Name")
			}

			StackFileContentsView(
				stackFileContent: $viewModel.stackFileContent,
				isFileImporterPresented: $viewModel.isFileImporterPresented,
				isStackFileContentsTargeted: $viewModel.isStackFileContentsTargeted,
				allowedContentTypes: allowedContentTypes,
				handleStackFileDrop: handleStackFileDrop
			)

			StackEnvironmentView(
				environment: $viewModel.stackEnvironment,
				isEnvironmentEntrySheetPresented: $viewModel.isEnvironmentEntrySheetPresented,
				editedEnvironmentEntry: $viewModel.editedEnvironmentEntry,
				removeEntryAction: { viewModel.editEnvironmentEntry(old: $0, new: nil) }
			)
		}
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
//		.navigationTitle(navigationTitle)
		#if os(iOS)
		.safeAreaInset(edge: .bottom) {
			createButton
				.buttonStyle(.customPrimary)
				.padding()
				.background(Color.groupedBackground)
		}
		#endif
		.fileImporter(isPresented: $viewModel.isFileImporterPresented, allowedContentTypes: allowedContentTypes) { result in
			handleFileResult(result)
		}
		.sheet(isPresented: $viewModel.isEnvironmentEntrySheetPresented) {
			viewModel.editedEnvironmentEntry = nil
		} content: {
			let oldEntry = viewModel.editedEnvironmentEntry
			NavigationStack {
				KeyValueEditView(entry: oldEntry) { newEntry in
					viewModel.editEnvironmentEntry(old: oldEntry, new: newEntry)
				} removeAction: {
					if let oldEntry {
						viewModel.editEnvironmentEntry(old: oldEntry, new: nil)
					}
				}
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.navigationTitle(oldEntry != nil ? "CreateStackView.EditEnvironmentValue" : "CreateStackView.AddEnvironmentValue")
				.addingCloseButton()
			}
			.presentationDetents([.medium])
			.presentationDragIndicator(.hidden)
			.presentationContentInteraction(.resizes)
			#if os(macOS)
			.sheetMinimumFrame(width: 320, height: 240)
			#endif
		}
		.toolbar {
			#if os(macOS)
			ToolbarItem(placement: .primaryAction) {
				createButton
			}
			#endif
		}
		.navigationTitle("CreateStackView.Title")
		.animation(.easeInOut, value: viewModel.isLoading)
		.animation(.easeInOut, value: viewModel.stackFileContent)
		.animation(.easeInOut, value: viewModel.stackEnvironment)
	}
}

// MARK: - CreateStackView+Actions

private extension CreateStackView {
	@MainActor
	func createStack() {
		Task {
			guard viewModel.canCreateStack else { return }

			do {
				Haptics.generateIfEnabled(.medium)
				let stack = try await viewModel.createStack().value

				dismiss()
				presentIndicator(.stackCreated(stack.name))
				Haptics.generateIfEnabled(.success)

				onStackCreation?(stack)
			} catch {
				errorHandler(error)
			}
		}
	}

	func handleFileResult(_ result: Result<URL, Error>) {
		do {
			let url = try result.get()
			let stackFileContents = try viewModel.loadStackFile(at: url)
			onStackFileSelection?(stackFileContents)
		} catch {
			errorHandler(error)
		}
	}

	func handleStackFileDrop(_ items: [NSItemProvider]) -> Bool {
		Haptics.generateIfEnabled(.selectionChanged)

		let item = items.first { $0.hasItemConformingToTypeIdentifier(UTType.yaml.identifier) }
		guard let item else { return false }

		Task {
			do {
				let stackFileContents = try await viewModel.handleStackFileDrop(item: item)
				onStackFileSelection?(stackFileContents)
			} catch {
				errorHandler(error)
			}
		}

		return true
	}
}

// MARK: - Previews

#Preview {
	NavigationStack {
		CreateStackView()
	}
}

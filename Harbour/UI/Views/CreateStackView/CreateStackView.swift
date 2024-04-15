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

	var body: some View {
		Form {
			NormalizedSection {
				TextField("CreateStackView.Name", text: $viewModel.stackName)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
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
				removeEntryAction: viewModel.removeEnvironmentEntry
			)
		}
		.scrollDismissesKeyboard(.interactively)
//		.navigationTitle(navigationTitle)
		.safeAreaInset(edge: .bottom) {
			Button {
				createStack()
			} label: {
				if viewModel.isLoading {
					ProgressView()
						.padding(.vertical, 2)
				} else {
					Label("CreateStackView.Create", systemImage: SFSymbol.plus)
				}
			}
			.buttonStyle(.customPrimary)
			.padding()
			.transition(.opacity)
			.disabled(!viewModel.canCreateStack)
			.disabled(viewModel.isLoading)
			.background(Color.groupedBackground)
		}
		.fileImporter(isPresented: $viewModel.isFileImporterPresented, allowedContentTypes: allowedContentTypes) { result in
			handleFileResult(result)
		}
		.sheet(isPresented: $viewModel.isEnvironmentEntrySheetPresented) {
			viewModel.editedEnvironmentEntry = nil
		} content: {
			let oldEntry = viewModel.editedEnvironmentEntry
			NavigationStack {
				KeyValueEditView(entry: oldEntry) { newEntry in
					viewModel.addOrEditEnvironmentEntry(old: oldEntry, new: newEntry)
				}
				.sheetHeader("CreateStackView.EditEnvironmentValue")
			}
			.presentationDetents(KeyValueEditView.presentationDetents)
			.presentationDragIndicator(.hidden)
		}
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
			do {
				Haptics.generateIfEnabled(.medium)
				let stack = try await viewModel.createStack().value

				dismiss()
				presentIndicator(.stackCreated(stack.name))

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

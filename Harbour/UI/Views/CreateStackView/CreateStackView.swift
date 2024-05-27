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
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel = ViewModel()
	@FocusState private var focusedField: FocusedField?

	var onEnvironmentEdit: (([KeyValueEntry]) -> Void)?
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
					.focused($focusedField, equals: .textfieldName)
			} header: {
				Text("CreateStackView.Name")
			}

			StackFileContentsView(
				stackFileContent: $viewModel.stackFileContent,
				showWholeStackFileContents: $viewModel.showWholeStackFileContents,
				isFileImporterPresented: $viewModel.isFileImporterPresented,
				isStackFileContentsTargeted: $viewModel.isStackFileContentsTargeted,
				allowedContentTypes: allowedContentTypes,
				handleStackFileDrop: handleStackFileDrop
			)
			.transition(.opacity)
			.onChange(of: viewModel.stackFileContent) {
				focusedField = nil
			}

			StackEnvironmentView(
				environment: $viewModel.stackEnvironment,
				isEnvironmentEntrySheetPresented: $viewModel.isEnvironmentEntrySheetPresented,
				editedEnvironmentEntry: $viewModel.editedEnvironmentEntry,
				removeEntryAction: { viewModel.editEnvironmentEntry(old: $0, new: nil) }
			)
			.onChange(of: viewModel.stackEnvironment) { _, newEntries in
				focusedField = nil
				onEnvironmentEdit?(newEntries)
			}
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
			handleStackFileResult(result)
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
		.transition(.opacity)
		.animation(.easeInOut, value: viewModel.isLoading)
		.animation(.easeInOut, value: viewModel.stackFileContent)
		.animation(.easeInOut, value: viewModel.stackEnvironment)
		.animation(.easeInOut, value: viewModel.showWholeStackFileContents)
	}
}

// MARK: - CreateStackView+FocusedField

private extension CreateStackView {
	enum FocusedField {
		case textfieldName
	}
}

// MARK: - CreateStackView+Actions

private extension CreateStackView {
	@MainActor
	func createStack() {
		Task {
			guard viewModel.canCreateStack else { return }

			let stackName = viewModel.stackName

			do {
//				presentIndicator(.stackCreate(stackName, nil, state: .loading))

				Haptics.generateIfEnabled(.medium)
				let stack = try await viewModel.createStack().value

				presentIndicator(.stackCreate(stackName, stack.id, state: .success) {
					Haptics.generateIfEnabled(.light)
					let navigationItem = StackDetailsView.NavigationItem(stackID: stack.id.description, stackName: stack.name)
					sceneDelegate.resetSheets()
					sceneDelegate.navigate(to: .stacks, with: navigationItem)
				})
				Haptics.generateIfEnabled(.success)
				onStackCreation?(stack)

				dismiss()
			} catch {
				presentIndicator(.stackCreate(stackName, nil, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func handleStackFileResult(_ result: Result<URL, Error>) {
		do {
			let url = try result.get()
			let stackFileContents = try viewModel.loadStackFile(at: url)
			Haptics.generateIfEnabled(.selectionChanged)
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
				Haptics.generateIfEnabled(.selectionChanged)
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
